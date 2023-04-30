# Environment tag for all resources being created. You can leave this value as-is.
environment_tag =   "sbx" # sbx = Sandbox, dev = Development, uat = UAT, prd = Production
company_name    =   "Rxt"
business_unit   =   "Latam-Presales-lh" # Don't put spaces, instead use - or _.
region          =   "us-east-1"

# Network address space for each environment
network_address_space = {
    sbx =   "192.168.0.0/19"
    dev =   "172.16.0.0/19"
    uat =   "10.20.0.0/19"
    prd =   "10.110.0.0/19"
}

# Subnets for each network environment
subnet_count = {
    sbx =   2
    dev =   2
    uat =   2
    prd =   3
}

# Compute for each network environment
vm_count = {
    sbx =   1
    dev =   1
    uat =   1
    prd =   1
}