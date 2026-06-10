import { installTinyShieldGame8 } from "../Compatibility/TinyShieldGame8.mjs";

export const game8Policy = Object.freeze({
    id: "game8-ad-shield",
    domains: Object.freeze(["game8.jp"]),
    scriptlets: Object.freeze([
        Object.freeze({
            name: "setRollingHashMarkers",
            options: Object.freeze({
                marker: "loader-check-10min"
            })
        })
    ]),
    compatibility: Object.freeze([
        installTinyShieldGame8
    ])
});
