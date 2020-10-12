# Terraform Components: AWS Spoke

You may find this module useful if you're building a "Hub and Spoke" layout network, as advocated
by various security firms, including Check Point and FortiNet.

## Role: Create AWS Spoke VPC and Subnets. Update routing tables and routes.

This role creates:

1. A single VPC, referred to as a "Spoke", with two subnets - one per Availability Zone.
2. Connections to a pre-defined Transit Gateway.
3. Routes and Routing to that Transit Gateway, and back out to this Spoke.

Optionally, this role also creates a VPC Flow Log, associated to the VPC. It requires a Global
IAM Role to be created and passed to this module, and also to have the VPC Flow Logs explicitly
enabled.

## Variables

* Defined in `_General.tf`.
  * `Project_Prefix`: This is the name associated to all resources created. Default: `demo`.
  * `AZ1`: The AZ to create all assets associated to the "first" AZ. If the region is `us-east-1`,
  the AZ `us-east-1a` would be recorded as `a`. Default: `a`.
  * `AZ2`: The AZ to create all assets associated ot the "second" AZ. Default: `b`.
* Defined in `VPC.tf`
  * `VPC_Suffix`: The suffix for the VPC, referenced in some other assets, like subnets and VPC
  flow logs. Default: `spoke`.
  * `IAM_Role_VPC_Flow_Logs_ARN`: The ARN (AWS Resource Name) for the IAM role which permits the
  creation of, and write access to a Cloudwatch Log Group, and this permits the VPC to write it's
  logs into this group. **Without this role being provided, flow logs will not be created.**
  Default: `null`.
  * `VPC_CIDR`: The CIDR mask of the VPC. It must be large enough to support 4 subnets. If you want
  to add additional subnets for your security appliances, then you must make sure this VPC is large
  enough to support them. Default: `198.51.100.0/24`.
  * `Enable_VPC_Flow_Logs`: Combined with `IAM_Role_VPC_Flow_Logs_ARN`, does this permit the VPC
  to create VPC flow logs? Default: `false`.
* Defined in `Subnets.tf`
  * `Subnet_Suffix`: The name for the created subnets in AZ1 and AZ2, attached to the VPC. Default:
  `subnet`.
  * `Subnet_CIDR_AZ1`: The CIDR for the subnet in AZ1. Default: `<empty>`. If left blank, will use
  the first ½ of the VPC CIDR.
  * `Subnet_CIDR_AZ2`: The CIDR for the subnet in AZ2. Default: `<empty>`. If left blank, will use
  the second ½ of the VPC CIDR.
* Defined in `Transit Gateway.tf`
  * `Transit_Gateway`: The Transit Gateway resource which this hub will be connected to.
  * `Transit_Gateway_Spoke_to_Hub_Routing_Table_ID`: The ID of the Transit Gateway Routing Table to
  attach to this spoke's attachment.
  * `Transit_Gateway_Hub_to_Spoke_Routing_Table_ID`: The ID of the Transit Gateway Routing Table
  which is attached to the hub's attachment.
  * `Transit_Gateway_Hub_To_Gateway_Attachment_ID`: The ID of the attachment from the Hub VPC to
  the Transit Gateway.
  * `Hub_Inspect_Routing_Table_ID`: The ID of the Routing Table to update with this spoke's CIDR.

## Outputs

* Defined in `VPC.tf`
  * `aws_vpc_vpc`: The VPC object created by this module.
  * `aws_vpc_vpc_id`: The ID of the VPC object created by this module.
* Defined in `Subnets.tf`
  * `aws_subnet_az1`: The subnet object in AZ1.
  * `aws_subnet_az1_id`: The ID of the subnet object in AZ1.
  * `aws_subnet_az2`: The subnet object in AZ2.
  * `aws_subnet_az2_id`: The ID of the subnet object in AZ2.
  * `aws_route_table_spoke`: The routing table object for the subnets in the spoke.
  * `aws_route_table_inspect_id`: The ID of the routing table object for the subnets in the spoke.
* Defined in `Transit Gateway.tf`
  * `aws_ec2_transit_gateway_vpc_attachment_spoke`: The attachment object created to join the Spoke
  to the Transit Gateway.
  * `aws_ec2_transit_gateway_vpc_attachment_spoke_id`: The ID of the attachment object created to
  join the Spoke to the Transit Gateway.
