# ntfy.nvim

This Neovim plugin will print NTFY messages from your subscribed topics inside Neovim.

Here is a quick demo!

[![Demo video](https://img.youtube.com/vi/93O0_d8-qLw/0.jpg)](https://www.youtube.com/watch?v=93O0_d8-qLw)

## Installation & configuration

> Lazy
  ```lua
  {
    "jorgegomzar/ntfy.nvim",
    opts = {
      subscribe_on_init = true,  -- default: true
      host = "ntfy.self_hosted.com",  -- default: ntfy.sh
      topics = {"nvim", "my_other_topic"}, -- default: {"nvim"} 
      port = 80,  -- default: 443
      username = "my_user",  -- default: nil
      password = "my_password", -- default: nil
      since = nil,  -- see: https://docs.ntfy.sh/subscribe/api/#fetch-cached-messages
    },
    dependencies = { "folke/noice.nvim" }
  },
  ```

Also, you can add extension to Telescope if you want to:

```lua
require("telescope").load_extension("ntfy")
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

## TODOs

- [ ] Update docs
- [ ] Support sending ntfy messages

