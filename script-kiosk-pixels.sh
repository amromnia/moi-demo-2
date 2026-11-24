#!/bin/bash
set -euo pipefail

# Inserts Meta + TikTok pixels into index.html just before </head>. Safe to re-run.

META_ID="1435757638482593"
FILE="index.html"

SNIPPET=$(cat << 'EOF_SNIPPET'
<!-- Meta Pixel Code -->
    <script>
    !function(f,b,e,v,n,t,s)
    {if(f.fbq)return;n=f.fbq=function(){n.callMethod?
    n.callMethod.apply(n,arguments):n.queue.push(arguments)};
    if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
    n.queue=[];t=b.createElement(e);t.async=!0;
    t.src=v;s=b.getElementsByTagName(e)[0];
    s.parentNode.insertBefore(t,s)}(window, document,'script',
    'https://connect.facebook.net/en_US/fbevents.js');
    fbq('init', '1435757638482593');
    fbq('track', 'PageView');
    </script>
    <noscript>
    <img height="1" width="1" style="display:none"
    src="https://www.facebook.com/tr?id=1435757638482593&ev=PageView&noscript=1"/>
    </noscript>
    <!-- End Meta Pixel Code -->
    <!-- TikTok Pixel Code Start -->
    <script>
    !function (w, d, t) {
      w.TiktokAnalyticsObject=t;var ttq=w[t]=w[t]||[];ttq.methods=["page","track",
      "identify","instances","debug","on","off","once","ready","alias","group",
      "enableCookie","disableCookie","holdConsent","revokeConsent","grantConsent"],
      ttq.setAndDefer=function(t,
      e){t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}};
      for(var i=0;i<ttq.methods.length;i++)ttq.setAndDefer(ttq,ttq.methods[i]);
      ttq.instance=function(t){for(
    var e=ttq._i[t]||[],n=0;n<ttq.methods.length;n++)ttq.setAndDefer(e,ttq.methods[n]);
      return e},ttq.load=function(e,
      n){var r="https://analytics.tiktok.com/i18n/pixel/events.js",o=n&&n.partner;
      ttq._i=ttq._i||{},ttq._i[e]=[],ttq._i[e]._u=r,ttq._t=ttq._t||{},
      ttq._t[e]=+new Date,ttq._o=ttq._o||{},ttq._o[e]=n||{};
      n=document.createElement("script")
    ;n.type="text/javascript",n.async=!0,n.src=r+"?sdkid="+e+"&lib="+t;
      e=document.getElementsByTagName("script")[0];e.parentNode.insertBefore(n,e)};

      ttq.load('DATRRLJC77U8O3I50JAG');
      ttq.page();
    }(window, document, 'ttq');
    </script>
    <!-- TikTok Pixel Code End -->
EOF_SNIPPET
)

echo "=== Adding tracking pixels ==="
echo "Current directory: $(pwd)"

if [ ! -f package.json ] || [ ! -f "$FILE" ]; then
  echo "Aborting: run this from the kiosk-website project root (needs package.json and $FILE)."
  echo "No files have been changed."
  exit 1
fi

if grep -q "$META_ID" "$FILE"; then
  echo "Pixels already present in $FILE — nothing to do."
  exit 0
fi

if ! grep -q '</head>' "$FILE"; then
  echo "Aborting: no </head> found in $FILE."
  echo "No files have been changed."
  exit 1
fi

BACKUP="$FILE.bak-$(date +%Y-%m-%d_%H-%M-%S)"
cp -a "$FILE" "$BACKUP"
echo "Backup written to $BACKUP"

CONTENT="$(cat "$FILE"; printf x)"
CONTENT="${CONTENT%x}"
BEFORE="${CONTENT%%</head>*}"
AFTER="${CONTENT#*</head>}"
printf '%s%s\n  </head>%s' "$BEFORE" "$SNIPPET" "$AFTER" > "$FILE"
echo "Inserted pixels into $FILE."

# stdin is detached so npm/pm2 can't swallow the rest of a `curl | bash` script.
echo ""
echo "=== Running npm run build ==="
npm run build < /dev/null

echo ""
echo "=== Restarting pm2 ==="
pm2 restart all < /dev/null

echo ""
echo "=== Update complete ==="
