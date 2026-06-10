// ==UserScript==
// @name         tinyShield for Safari and game8.jp
//
// @namespace    https://github.com/FilteringDev/tinyShield
// @homepageURL  https://github.com/FilteringDev/tinyShield
// @supportURL   https://github.com/FilteringDev/tinyShield/issues
// @updateURL    https://cdn.jsdelivr.net/npm/@filteringdev/tinyshield@latest/dist/grouped/g/tinyShield-game8.jp.user.js
// @downloadURL  https://cdn.jsdelivr.net/npm/@filteringdev/tinyshield@latest/dist/grouped/g/tinyShield-game8.jp.user.js
// @license      MPL-2.0
//
// @version      3.9.0
// @author       PiQuark6046 and contributors
//
// @grant        unsafeWindow
// @run-at       document-start
//
// @description  tinyShield allows AdGuard, uBlock Origin, Brave and ABP to resist against Ad-Shield quickly.
// @description:ko  tinyShield는 AdGuard, uBlock Origin, Brave 와 ABP가 애드쉴드에 빠르게 저항할 수 있도록 합니다.
// @description:ja  tinyShieldを使うと、AdGuard, uBlock Origin, Brave, およびABPがAd-Shieldに素早く対抗できます。
//
// @match      *://game8.jp/*
// @match      *://*.game8.jp/*
// ==/UserScript==

export function installTinyShieldGame8() {

(()=>{var C={MaxTopLevelKeys:300,MaxArrayItems:1e3,MaxInnerKeysPerObject:100,MaxOperations:1e4},S=["device","id","imp","regs","site","source"],I=Object.prototype.propertyIsEnumerable;function d(t,e){return I.call(t,e)}function j(t){let e=0;for(let n of S)d(t,n)&&e++;return e}function x(t,e=C){let n=0,o=(r=1)=>(n+=r,n<=e.MaxOperations);try{let r=t[0];if(!o(S.length))return{Status:"too-expensive"};if(j(r)<5)return{Status:"not-matched"};let s=/^[0-9]+\/[a-zA-Z0-9]+\/[a-zA-Z0-9]+\/[a-z0-9-\(\)]+\/[a-zA-Z0-9_]+_slot[0-9]+_+/,u=0;for(let f in r){if(!d(r,f))continue;if(u++,u>e.MaxTopLevelKeys||!o())return{Status:"too-expensive"};let i=r[f];if(!Array.isArray(i))continue;let y=Math.min(i.length,e.MaxArrayItems);for(let m=0;m<y;m++){if(!o())return{Status:"too-expensive"};let p=i[m];if(typeof p!="object"||p===null)continue;let k=0;for(let w in p)if(d(p,w)){if(k++,k>e.MaxInnerKeysPerObject||!o())return{Status:"too-expensive"};if(l.call(s,w))return{Status:"matched"}}}if(i.length>e.MaxArrayItems)return{Status:"too-expensive"}}return{Status:"not-matched"}}catch(r){return{Status:"unsafe-object",Reason:r}}}var g="[object ",Z=["[object ","[native code]","function ","=>","HTMLElement","HTML","ShadowRoot","Comment","Text","Object"],T=["HTMLElement]","ShadowRoot]","Comment]","Text]"],P=new Set(["","true","false"]);function b(t){if(t.length<512)return!1;let e=t.length>4096?t.slice(0,4096):t;if(!e.includes(g)||M(e,g)<10||M(e,",")<50||!Z.some(i=>e.includes(i)))return!1;let s=e.split(",");if(s.length<50)return!1;let u=0;for(let i of s){let y=i.trim();E(y)&&(u+=1)}return u/s.length>=.65}function E(t){return P.has(t)||W(t)||t.startsWith(g)||T.some(e=>t.includes(e))?!0:t.includes("[native code]")||t.startsWith("function ")||t.startsWith("()=>")}function W(t){if(t.length===0)return!1;let e=0;if(t[0]==="-"){if(t.length===1)return!1;e=1}for(let n=e;n<t.length;n+=1){let o=t.charCodeAt(n);if(o<48||o>57)return!1}return!0}function M(t,e){let n=0,o=0;for(;;){let r=t.indexOf(e,o);if(r===-1)break;n+=1,o=r+e.length}return n}function h(t,e){let n=e.OriginalArrayMap.call(t,o=>o&&typeof o=="object"&&e.OriginalObjectGetPrototypeOf(o)===null?"[Object: null prototype]":e.OriginalString(o));return e.OriginalArrayJoin.call(n)}var a=typeof unsafeWindow<"u"?unsafeWindow:window,c="tinyShield",l=a.RegExp.prototype.test,A=a.Array.prototype.map,R=a.String,O=a.Array.prototype.join,v=a.Object.getPrototypeOf,K=["toString","get","set"];a.Function.prototype.toString=new Proxy(a.Function.prototype.toString,{apply(t,e,n){return K.includes(e.name)?`function ${e.name}() { [native code] }`:Reflect.apply(t,e,n)}});var L=[[/[a-zA-Z0-9]+ *=> *{ *const *[a-zA-Z0-9]+ *= *[a-zA-Z0-9]+ *; *if/,/===? *[a-zA-Z0-9]+ *\[ *[a-zA-Z0-9]+\( *[0-9a-z]+ *\) *\] *\) *return *[a-zA-Z0-9]+ *\( *{ *('|")?inventoryId('|")? *:/,/{ *('|")?inventoryId('|")? *: *this *\[[a-zA-Z0-9]+ *\( *[0-9a-z]+ *\) *\] *, *\.\.\. *[a-zA-Z0-9]+ *\[ *[a-zA-Z0-9]+ *\( *[0-9a-z]+ * *\) *\] *} *\)/]];a.Map.prototype.get=new Proxy(a.Map.prototype.get,{apply(t,e,n){if(n.length>0&&typeof n[0]!="function")return Reflect.apply(t,e,n);let o=h(n,{OriginalArrayMap:A,OriginalString:R,OriginalArrayJoin:O,OriginalObjectGetPrototypeOf:v});if(!b(o)&&L.filter(r=>r.filter(s=>l.call(s,o)).length>=2).length===1)throw console.debug(`[${c}]: Map.prototype.get:`,e,n),new Error;return Reflect.apply(t,e,n)}});var U=[{Search:[/inventory_id,[a-zA-Z0-9-]+\/[a-zA-Z0-9]+\/[a-zA-Z0-9]+/,/inventory_id,[a-zA-Z0-9-]+\/[a-zA-Z0-9]+\/[a-zA-Z0-9]+/,/inventory_id,[a-zA-Z0-9-]+\/[a-zA-Z0-9]+\/[a-zA-Z0-9]+/],ArgsType:{Key:"string",Value:["string"]}},{Search:[/[a-z0-9A-Z]+\.setAttribute\( *('|")onload('|") *, *('|")! *async *function\( *\) *\{ *let */,/confirm\( *[A-Za-z0-9]+ *\) *\) *{ *const *[A-Za-z0-9]+ *= *new *[A-Za-z0-9]+\.URL\(('|")https:\/\/report\.error-report\.com\//,/\.forEach *\( *\( *[A-Za-z0-9]+ *=> *[A-Za-z0-9]+\.remove *\( *\) *\) *\) *\) *, *[0-9a-f]+ *\) *; *const *[A-Za-z0-9]+ *= *awai,t *\( *await *fetch *\(/],ArgsType:{Key:"string",Value:["function"]}}];function D(t,e){let n=typeof t[0],o=typeof t[1];return n!==e.Key?!1:e.Value.includes(o)}a.Map.prototype.set=new Proxy(a.Map.prototype.set,{apply(t,e,n){let o="",r=U.filter(s=>D(n,s.ArgsType));if(r.length===0)return Reflect.apply(t,e,n);if(o=h(n,{OriginalArrayMap:A,OriginalString:R,OriginalArrayJoin:O,OriginalObjectGetPrototypeOf:v}),!b(o)&&r.filter(s=>s.Search.filter(u=>l.call(u,o)).length>=3).length===1)throw console.debug(`[${c}]: Map.prototype.set:`,e,n),new Error;return Reflect.apply(t,e,n)}});a.WeakMap.prototype.set=new Proxy(a.WeakMap.prototype.set,{apply(t,e,n){let o=x(n);switch(o.Status){case"matched":throw console.debug(`[${c}]: WeakMap.prototype.set:`,e,n),new Error;case"not-matched":break;case"too-expensive":console.warn(`[${c}]: WeakMap.prototype.set: Check too expensive:`,e,n);break;case"unsafe-object":console.warn(`[${c}]: WeakMap.prototype.set: Unsafe object:`,e,n,o.Reason);break}return Reflect.apply(t,e,n)}});var z=[[/async *\( *\) *=> *{ *const *[A-Za-z0-9]+ *= *[A-Za-z0-9]+ *; *await *[A-Za-z0-9]+ *\( *\)/,/; *await *[A-Za-z0-9]+ *\( *\) *, *[A-Za-z0-9]+ *\( *! *1 *, *new *Error *\( *[A-Za-z0-9]+ *\( *[0-9a-f]+ *\) *\) *\) *}/,/ *\) *\) *\) *}/]];a.setTimeout=new Proxy(a.setTimeout,{apply(t,e,n){if(z.filter(o=>o.filter(r=>r.test(n[0].toString())).length>=3).length===1){console.debug(`[${c}]: setTimeout:`,n);return}return Reflect.apply(t,e,n)}});a.setInterval=new Proxy(a.setInterval,{apply(t,e,n){if(z.filter(o=>o.filter(r=>r.test(n[0].toString())).length>=3).length===1){console.debug(`[${c}]: setInterval:`,n);return}return Reflect.apply(t,e,n)}});})();
/*!
 * @license MPL-2.0
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Contributors:
 *   - See Git history at https://github.com/FilteringDev/tinyShield for detailed authorship information.
 */
}
