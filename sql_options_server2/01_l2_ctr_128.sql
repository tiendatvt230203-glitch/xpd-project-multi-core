DELETE FROM xdp_local_configs WHERE config_id = 1;
DELETE FROM xdp_wan_configs  WHERE config_id = 1;
DELETE FROM xdp_configs      WHERE id = 1;

INSERT INTO xdp_configs (
    id,
    crypto_enabled,
    crypto_key,
    encrypt_layer,
    fake_protocol,
    crypto_mode,
    aes_bits,
    nonce_size,
    fake_ethertype_ipv4,
    fake_ethertype_ipv6
) VALUES
(1, 1, '2b7e151628aed2a6abf7158809cf4f3c', 2, 0, 'ctr', 128, 16, '88B6', '88B7');

INSERT INTO xdp_local_configs (
    config_id,
    ifname,
    network,
    src_mac,
    dst_mac
) VALUES
(1, 'enp7s0', '192.168.9.0/24', '20:7c:14:f8:0d:08', '20:7c:14:f8:0c:d2');

INSERT INTO xdp_wan_configs (
    config_id,
    ifname,
    src_mac,
    dst_mac
) VALUES
(1, 'enp4s0', '20:7c:14:f8:0d:4d', '20:7c:14:f8:0c:cf'),
(1, 'enp5s0', '20:7c:14:f8:0d:4e', '20:7c:14:f8:0c:d0'),
(1, 'enp6s0', '20:7c:14:f8:0d:4f', '20:7c:14:f8:0c:d1');

