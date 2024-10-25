# ntfy.nvim

This Neovim plugin will print NTFY messages from your subscribed topics inside Neovim.

## ⚠️ This plugin functional but is still under development

I will try to not introduce breaking changes but just so you know this code is poorly tested and not documented at all yet!

- [ ] Support multiple topics
- [ ] Support sending ntfy messages
- [ ] Make tests pass + add more
- [ ] Update docs

## Installation & configuration

> Lazy
  ```lua
  {
    "jorgegomzar/ntfy.nvim",
    opts = {
      subscribe_on_init = true,  -- default: true
      host = "ntfy.self_hosted.com",  -- default: ntfy.sh
      topics = {"nvim"}, -- default: {"nvim"}. Currently only 1 topic is supported
      port = 80,  -- default: 443
      username = "my_user",  -- default: nil
      password = "my_password", -- default: nil
    },
  },
  ```

## Extra considerations

This plugin connects to the NTFY host SSE stream. If you are self hosting your own NTFY server make sure your proxy is correctly configured.

I had some struggles but found that this nginx configuration worked for me:

```conf
location / {
    proxy_pass http://127.0.0.1:4001;  # or wherever your ntfy server is running
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For "$http_x_forwarded_for, $realip_remote_addr";
    proxy_set_header Connection '';
    proxy_http_version 1.1;
    chunked_transfer_encoding off;
    proxy_buffering off;
    proxy_cache off;
}
```
