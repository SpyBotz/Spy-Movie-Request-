SPY MOVIE REQUEST — GitHub Pages edition
==========================================

This version does NOT use Supabase, Firebase, login, or a database.

Files:
- index.html: website
- README.txt: setup instructions

Deploy on GitHub Pages:
1. Open your GitHub repository.
2. Upload index.html to the repository root (same level as README).
3. If an old index.html exists, replace it with this one.
4. Open repository Settings → Pages.
5. Under Build and deployment, select Deploy from a branch.
6. Select branch main and folder /(root), then Save.
7. Wait for the Pages deployment and open your website.

Configure your links:
1. Open index.html in GitHub and tap Edit (pencil).
2. Find the CONFIG section near the bottom.
3. Replace:
   adminWhatsAppNumber: "91YOURNUMBER"
   with your WhatsApp number including country code, digits only.
   Example India number: 919876543210
4. Replace whatsappChannelUrl, telegramChannelUrl, and paidChannelUrl with your real links.
5. Commit changes.

Important limitations:
- This is a static website. It does not save requests or chat history in a shared database.
- Movie requests are composed as WhatsApp messages; the visitor must press Send in WhatsApp.
- No member/admin login or private chat is included.
- Do not put passwords, API secrets, or private keys in index.html.
