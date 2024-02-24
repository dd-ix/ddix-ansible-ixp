-- This query create a view  on the IXP-Manager tables containing
-- all the required peer data to build:
-- - arouteserver's clients.yml (including md5 secrets)
-- - switchport configs including l2 address filters
CREATE OR REPLACE VIEW `__DDIX__peers` AS
SELECT `vlan`.`number` AS `vlanid`,
  `cu`.`name` AS `custname`,
  `cu`.`shortname` AS `slug`,
  `cu`.`autsys` AS `asn`,
  `pi`.`status` AS `status`,
  `sw`.`name` AS `switchname`,
  `sp`.`name` AS `switchport`,
  `sp`.`ifIndex` AS `switchifidx`,
  `l2address`.`mac` AS `l2address`,
  `cu`.`maxprefixes` AS `maxprefixes`,
  `vli`.`ipv4enabled` AS `ipv4enabled`,
  `cu`.`peeringmacro` AS `ipv4peeringmacro`,
  `vli`.`ipv4hostname` AS `ipv4hostname`,
  `vli`.`ipv4bgpmd5secret` AS `ipv4bgpmd5secret`,
  `v4`.`address` AS `ipv4address`,
  `vli`.`ipv6enabled` AS `ipv6enabled`,
  `cu`.`peeringmacrov6` AS `ipv6peeringmacro`,
  `vli`.`ipv6hostname` AS `ipv6hostname`,
  `vli`.`ipv6bgpmd5secret` AS `ipv6bgpmd5secret`,
  `vli`.`rsclient` AS `rsclient`,
  `v6`.`address` AS `ipv6address`
FROM (
    (
      `physicalinterface` `pi`
      JOIN `virtualinterface` `vi`
    )
    JOIN (
      (
        (
          `vlaninterface` `vli`
          LEFT JOIN `ipv4address` `v4` ON(`vli`.`ipv4addressid` = `v4`.`id`)
        )
        LEFT JOIN `ipv6address` `v6` ON(`vli`.`ipv6addressid` = `v6`.`id`)
      )
      LEFT JOIN `vlan` on(`vli`.`vlanid` = `ixp_manager`.`vlan`.`id`)
      LEFT JOIN `l2address` ON(`l2address`.`vlan_interface_id` = `vli`.`id`)
    )
    JOIN `cust` `cu` ON(`cu`.`id` = `vi`.`custid`)
    JOIN `switchport` `sp` ON(`pi`.`switchportid` = `sp`.`id`)
    JOIN `switch` `sw` ON(`sp`.`switchid` = `sw`.`id`)
  )
WHERE `pi`.`virtualinterfaceid` = `vi`.`id`
  AND `vli`.`virtualinterfaceid` = `vi`.`id`
  AND `ixp_manager`.`vlan`.`id` = 1
