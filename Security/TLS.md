### TLS
TLS (Transport Layer Security) is a network protocol evolved from SSL (Secure Sockets Layer).   
It operates directly on top of TCP and extensively utilized by HTTPS transport protocol.

Primarily, it includes:
1. Conversational algorithm named `Handshake` to establish server identity - `Server Authentication`.   
`Handshake` also may include `Client Authentication` to forbid the access for untrusted clients.
2. Record algorithm for encrypting outgoing and decrypting incoming messages using `Symmetric` `Session Key` obtained during `Handshake`.
