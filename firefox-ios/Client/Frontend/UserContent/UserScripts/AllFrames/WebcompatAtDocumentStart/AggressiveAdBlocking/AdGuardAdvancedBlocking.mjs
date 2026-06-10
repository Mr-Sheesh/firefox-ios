import { ContentScript } from "./Vendor/AdGuardSafariContentScript.mjs";

export function installAdGuardAdvancedBlocking() {
    const handler = window.webkit?.messageHandlers?.adGuardAdvancedBlocking;
    if (!handler) {
        return;
    }

    const requestId = globalThis.crypto?.randomUUID?.() ??
        `${Date.now()}-${Math.random().toString(16).slice(2)}`;
    const pageUrl = location.href;
    const contentScript = new ContentScript();
    const maximumAttempts = 40;
    let attempts = 0;
    let retryTimer;

    const bridge = {
        apply(payload) {
            if (payload?.requestId !== requestId ||
                payload?.pageURL !== location.href) {
                return;
            }

            clearTimeout(retryTimer);
            delete window.__firefoxIOSAdGuardAdvanced;
            contentScript.applyConfiguration(payload.configuration);
        }
    };

    const requestConfiguration = () => {
        if (window.__firefoxIOSAdGuardAdvanced !== bridge) {
            return;
        }
        if (attempts >= maximumAttempts) {
            delete window.__firefoxIOSAdGuardAdvanced;
            return;
        }

        attempts += 1;
        handler.postMessage({
            requestId,
            pageUrl,
            topUrl: window.top === window ? null : document.referrer || null
        });
        retryTimer = setTimeout(requestConfiguration, 250);
    };

    Object.defineProperty(window, "__firefoxIOSAdGuardAdvanced", {
        configurable: true,
        value: bridge
    });

    requestConfiguration();
}
