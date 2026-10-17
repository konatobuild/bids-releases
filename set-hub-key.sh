# Copy the Hub key (from iMessage) first, then run this. Never prints the key.
set -e
A="$HOME/Applications/bids.app/Contents/Resources"; [ -d "$A" ] || A="/Applications/bids.app/Contents/Resources"
K=$(pbpaste | tr -d ' \n\r\t')
[ ${#K} -eq 64 ] || { echo "剪贴板里不是钥匙（应该是 64 个字符）。请先从 iMessage 复制钥匙，再运行一次。"; exit 1; }
mkdir -p "$HOME/.agenthub"; chmod 700 "$HOME/.agenthub"
C="$HOME/.agenthub/config.json"
[ -f "$C" ] && cp "$C" "$HOME/.agenthub/config.json.before-cloud-$(date +%Y%m%d-%H%M%S)"
umask 077; printf '%s\n' "$K" > "$HOME/.agenthub/cloud.key"; chmod 600 "$HOME/.agenthub/cloud.key"
"$A/node" -e '
const fs=require("fs"),p=process.argv[1]; let c={}; try{c=JSON.parse(fs.readFileSync(p,"utf8"))}catch{}
c.remote={...(c.remote||{}),url:"https://agenthub-api.konatobuild.workers.dev",keyFile:"cloud.key"};
fs.writeFileSync(p,JSON.stringify(c,null,2)+"\n"); console.log("已写入云端 Hub 地址和钥匙。")' "$C"
echo "x" | pbcopy
echo "检查连接："
curl -fsSL https://raw.githubusercontent.com/konatobuild/bids-releases/main/check-hub.sh | sh
echo "如果上面显示 area = yangyang，退出 bids（⌘Q）再打开就能看到 Hub 的数据。"
