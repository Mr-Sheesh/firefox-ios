export function hostnameMatches(hostname, domain) {
    const normalizedHostname = hostname.toLowerCase().replace(/\.$/, "");
    const normalizedDomain = domain.toLowerCase().replace(/^\./, "").replace(/\.$/, "");
    return normalizedHostname === normalizedDomain ||
        normalizedHostname.endsWith(`.${normalizedDomain}`);
}

export function matchingPolicies(hostname, policies) {
    return policies.filter(policy =>
        policy.domains.some(domain => hostnameMatches(hostname, domain))
    );
}

export function runAdBlockPolicies({ hostname, target, policies, scriptlets }) {
    for (const policy of matchingPolicies(hostname, policies)) {
        for (const invocation of policy.scriptlets ?? []) {
            const scriptlet = scriptlets[invocation.name];
            if (!scriptlet) {
                continue;
            }

            try {
                scriptlet(target, invocation.options ?? {});
            } catch (error) {
                console.debug(`[Firefox AdBlock] ${policy.id}/${invocation.name} failed`, error);
            }
        }

        for (const installCompatibility of policy.compatibility ?? []) {
            try {
                installCompatibility();
            } catch (error) {
                console.debug(`[Firefox AdBlock] ${policy.id} compatibility failed`, error);
            }
        }
    }
}
