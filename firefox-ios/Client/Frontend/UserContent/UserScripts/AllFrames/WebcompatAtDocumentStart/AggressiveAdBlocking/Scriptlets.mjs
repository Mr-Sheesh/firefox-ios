function stringHash(value) {
    let result = 0;
    for (let index = 0; index < value.length; index++) {
        result = ((result << 5) - result + value.charCodeAt(index)) | 0;
    }
    return result;
}

export function setRollingHashMarkers(
    target,
    {
        hostname = location.hostname,
        marker,
        interval = 600000,
        offsets = [-1, 0, 1],
        now = Date.now()
    }
) {
    if (!marker || interval <= 0) {
        return;
    }

    const currentWindow = now - now % interval;
    for (const offset of offsets) {
        const timestamp = currentWindow + offset * interval;
        const key = `as_${timestamp / interval % 10}` +
            stringHash(`${hostname}${marker}_${timestamp}`);
        target[key] = true;
    }
}

export const scriptlets = Object.freeze({
    setRollingHashMarkers
});
