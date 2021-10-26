# VPN - OpenVPN
## Environment
- OS : pfSense 2.5.x

## Create CAs
- Menu : System -> Cert. Manager -> CAs
- Create new CA
  ```
  - Discriptive name : {discriptive name}
  - Method : Create an internal Certificate Authority
  - Key type : RSA or ECDSA (Elliptic Curve Digital Signature Algorithm)
        * RSA keys are more common and well-supported than ECDSA, as well as having some performance benefits.
        * ECDSA is slower at verifying signatures than RSA, but scales better
  - Key type size : 2048 or 4096
  - Digest Algorithm : Minimum of SHA-256, recommend SHA-512
  - Lifetime (days) : 3650 (=10 Years)
  - Common Name : internal-ca
  - Country Code : {country code}
  - State or Province : {state or province}
  - City : {city}
  - Organization : {organization}
  - Organizational Unit : {organizational unit}
  ```
## Create new OpenVPN access users
- Menu : System -> User Manager
- Create new OpenVPN group.
  ```
  - Group name : {group name}
  - Scope : local
  - Discription : {discription}
  - Assigned Privileges : User - Config: Deny Config Write
  ```
- Create new OpenVPN user.
  ```
  - Username : {username}
  - Password : {password}
  - Full name : {full name}
  - Group membership : {group name}
  - Certificate : Checked
    - Certificate Authority : Select {discriptive name}
  ```

## Setting OpenVPN
  - Menu : VPN -> OpenVPN
  - Create new OpenVPN Servers using wizards.
    ```
    [Page.1]
       - Type of Server : Local User Access

    [Page.2]
       - Certificate Authority : {discriptive name}

    [Page.3]
       - Certificate : {discriptive name}

    [Page.4]
       - Interface : WAN
       - Protocol : UDP on IPv4 only
       - Local Port : 1194
       - Discription : {discription}
       - Tunnel Network : {These are the pools of addresses to be assigned to clients upon connecting.}
       - Redirect Gateway : Checked
       - Local Network : {These fields specify which local networks are reachable by VPN clients, if any.}
    ```
