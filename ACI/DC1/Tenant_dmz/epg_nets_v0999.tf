/*
API Information:
 - Class: "fvAEPg"
 - Distinguished Name: /uni/tn-dmz/ap-nets/epg-v0999
GUI Location:
Tenants > dmz > Application Profiles > nets > Application EPGs > v0999
*/
resource "aci_application_epg" "nets_v0999" {
	depends_on						= [aci_tenant.dmz,aci_application_profile.dmz_nets]
	application_profile_dn			= aci_application_profile.dmz_nets.id
	name							= "v0999"
	description						= "dirtyDMZ"
	flood_on_encap					= "disabled"
	has_mcast_source				= "no"
	is_attr_based_epg				= "no"
	match_t							= "AtleastOne"
	pc_enf_pref						= "enforced"
	pref_gr_memb					= "exclude"
	prio							= "level3"
	shutdown						= "no"
	relation_fv_rs_bd				= aci_bridge_domain.dmz_v0999.id
	relation_fv_rs_aepg_mon_pol		= "uni/tn-common/monepg-default"
}

/*
API Information:
 - Class: "fvRsDomAtt"
 - Distinguished Name: /uni/tn-dmz/ap-nets/epg-v0999/rsdomAtt-[uni/phys-access_phys]
GUI Location:
Tenants > dmz > Application Profiles > nets > Application EPGs > v0999 > Domains (VMs and Bare-Metals)
*/
resource "aci_rest" "nets_v0999_phys-access_phys" {
	depends_on		= [aci_application_epg.nets_v0999]
	path		= "/api/node/mo/uni/tn-dmz/ap-nets/epg-v0999.json"
	class_name	= "fvRsDomAtt"
	payload		= <<EOF
{
    "fvRsDomAtt": {
        "attributes": {
            "tDn": "uni/phys-access_phys"
        },
        "children": []
    }
}
	EOF
}

/*
API Information:
 - Class: "fvRsPathAtt"
 - Distinguished Name: "uni/tn-dmz/ap-nets/epg-v0999/rspathAtt-[topology/pod-1/protpaths-201-202/pathep-[pg_vpc1_dc1-leaf201]"
GUI Location:
Tenants > dmz > Application Profiles > nets > Application EPGs > v0999 > Static Ports > Pod-1/Node-201-202/pg_vpc1_dc1-leaf201
*/
resource "aci_epg_to_static_path" "nets_v0999_Pod-1_Nodes-201-202_pg_vpc1_dc1-leaf201" {
	depends_on           = [aci_application_epg.nets_v0999]
	application_epg_dn   = aci_application_epg.nets_v0999.id
	tdn                  = "topology/pod-1/protpaths-201-202/pathep-[pg_vpc1_dc1-leaf201]"
	encap                = "vlan-999"
	mode                 = "regular"
}

/*
API Information:
 - Class: "fvRsPathAtt"
 - Distinguished Name: "uni/tn-dmz/ap-nets/epg-v0999/rspathAtt-[topology/pod-1/protpaths-201-202/pathep-[pg_vpc7_dc1-leaf201]"
GUI Location:
Tenants > dmz > Application Profiles > nets > Application EPGs > v0999 > Static Ports > Pod-1/Node-201-202/pg_vpc7_dc1-leaf201
*/
resource "aci_epg_to_static_path" "nets_v0999_Pod-1_Nodes-201-202_pg_vpc7_dc1-leaf201" {
	depends_on           = [aci_application_epg.nets_v0999]
	application_epg_dn   = aci_application_epg.nets_v0999.id
	tdn                  = "topology/pod-1/protpaths-201-202/pathep-[pg_vpc7_dc1-leaf201]"
	encap                = "vlan-999"
	mode                 = "regular"
}

/*
API Information:
 - Class: "fvRsPathAtt"
 - Distinguished Name: "uni/tn-dmz/ap-nets/epg-v0999/rspathAtt-[topology/pod-1/protpaths-201-202/pathep-[pg_vpc9_dc1-leaf201]"
GUI Location:
Tenants > dmz > Application Profiles > nets > Application EPGs > v0999 > Static Ports > Pod-1/Node-201-202/pg_vpc9_dc1-leaf201
*/
resource "aci_epg_to_static_path" "nets_v0999_Pod-1_Nodes-201-202_pg_vpc9_dc1-leaf201" {
	depends_on           = [aci_application_epg.nets_v0999]
	application_epg_dn   = aci_application_epg.nets_v0999.id
	tdn                  = "topology/pod-1/protpaths-201-202/pathep-[pg_vpc9_dc1-leaf201]"
	encap                = "vlan-999"
	mode                 = "regular"
}

