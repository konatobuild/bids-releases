A="$HOME/Applications/bids.app/Contents/Resources"; [ -d "$A" ] || A="/Applications/bids.app/Contents/Resources"
echo "bids: $A $( /usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$A/../Info.plist" 2>/dev/null )"
C="$HOME/.agenthub/config.json"
if [ -f "$C" ]; then "$A/node" -e '
const c=require(process.argv[1]); const r=c.remote||{};
console.log("hub config: remote url", r.url||"MISSING", "| keyFile", r.keyFile||"MISSING");
if(r.keyFile){const p=require("path").resolve(require("os").homedir(),".agenthub",r.keyFile);const fs=require("fs");
 try{const s=fs.statSync(p);console.log("key file:", p, "mode", (s.mode&0o777).toString(8), "length", fs.readFileSync(p,"utf8").trim().length)}catch(e){console.log("key file: MISSING", p)}}' "$C"; else echo "hub config: $C MISSING"; fi
S="$HOME/Library/Application Support/bids"; ls "$S" 2>/dev/null | tr '\n' ' '; echo
[ -f "$S/setup-patch.json" ] && "$A/node" -e 'for (const m of require(process.argv[1])) if (m.module==="opportunity-library") console.log("hub module: node", m.value.node, "| executable", m.value.executable)' "$S/setup-patch.json"
(printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"check","version":"1"}}}' '{"jsonrpc":"2.0","method":"notifications/initialized"}' '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"hub_feed","arguments":{"peek":true,"limit":1}}}'; sleep 8) | HUB_AGENT=check "$A/node" "$A/agenthub/bin/agenthub.js" mcp 2>&1 | "$A/node" -e '
let b="";process.stdin.on("data",d=>b+=d).on("end",()=>{for(const l of b.split("\n")){try{const m=JSON.parse(l);if(m.id===2){const t=m.result?.content?.[0]?.text||JSON.stringify(m.error||m.result);const i=t.indexOf("{");let me="";try{me=JSON.parse(t.slice(i,t.lastIndexOf("}")+1)).me}catch{};console.log("hub read:", me?("OK, area = "+me):t.slice(0,300))}}catch{}}})'
