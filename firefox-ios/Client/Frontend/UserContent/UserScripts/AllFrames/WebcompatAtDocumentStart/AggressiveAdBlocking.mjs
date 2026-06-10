import { installAdGuardAdvancedBlocking } from "./AggressiveAdBlocking/AdGuardAdvancedBlocking.mjs";
import { runAdBlockPolicies } from "./AggressiveAdBlocking/PolicyRunner.mjs";
import { scriptlets } from "./AggressiveAdBlocking/Scriptlets.mjs";
import { sitePolicies } from "./AggressiveAdBlocking/SitePolicies.mjs";

if (window.__firefoxIOSAggressiveAdBlocking) {
    delete window.__firefoxIOSAggressiveAdBlocking;
    installAdGuardAdvancedBlocking();
    runAdBlockPolicies({
        hostname: location.hostname,
        target: window,
        policies: sitePolicies,
        scriptlets
    });
}
