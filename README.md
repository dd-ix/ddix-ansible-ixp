# DD-IX Bird & Switch Deployment

This deployment builds the configurations for:
- DD-IX IXP Switches (Arista EOS)
- DD-IX Route Server BGP Config (Bird)
- DD-IX SFlow Exporter (sflow-exporter)

The configs are based on:
- a custome [SQL view](ixp-manager_peers.sql) from the database of the DD-IX IXP-Manager instance
- [arouteserver](https://github.com/pierky/arouteserver) building the bird.conf

Config knobs:
- [Arista EOS templates](templates/eos/)
- [arouteserver directory](arouteserver/)
- [sflow-exporter config seed](roles/sflow_build/templates/meta.yml.j2)
