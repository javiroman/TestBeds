# EasyRSA Role

Adrian Ramos, 2020

Automatic creation of CAs, sub CAs and certificates with [EasyRSA](https://github.com/OpenVPN/easy-rsa).

This role uses by default EasyRSA version 3.0.8.

## Requirements

None

## Variables

For a list of configuration variables available see the `defaults/main.yml`

## Dependencies

None

## Example(s)

### PKI and CA creation

```yml
- hosts: '{{ servers }}'
  become: yes

  roles:
    - easyrsa

  vars:
    easyrsa_pki_dir: /etc/ssl/pki
    easyrsa_ca_cn: easyrsaCA
```

### PKI, CA and Certs creation

```yml
- hosts: '{{ servers }}'
  become: yes

  roles:
    - easyrsa

  vars:
    easyrsa_pki_dir: /etc/ssl/pki
    easyrsa_ca_cn: easyrsaCA
    easyrsa_cert_list:
    - easyrsa_cert_req_cn: server1
      easyrsa_cert_days: 730
      easyrsa_cert_x509_type: server
    - easyrsa_cert_req_cn: client1
      easyrsa_cert_days: 730
      easyrsa_cert_x509_type: client
```

The generated certificates can be reached on `easyrsa_pki_dir/issued`, and keys on `easyrsa_pki_dir/private`.

## License

AGPLv3
