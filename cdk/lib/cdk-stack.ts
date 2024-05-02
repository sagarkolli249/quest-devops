import * as cdk from 'aws-cdk-lib';
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as elbv2 from "aws-cdk-lib/aws-elasticloadbalancingv2";
import { Construct } from 'constructs';
import { DockerImageAsset } from 'aws-cdk-lib/aws-ecr-assets';
import * as acm from 'aws-cdk-lib/aws-certificatemanager'
import * as route53 from 'aws-cdk-lib/aws-route53'
import path = require('path');

const HostedZoneID = "Z01561112EXM35V9RKPDM"

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc = new ec2.Vpc(this, "MyVpc", {
      maxAzs: 3 // Default is all AZs in region
    });

    const cluster = new ecs.Cluster(this, "MyCluster", {
      vpc: vpc
    });

    const taskDefinition  = new ecs.FargateTaskDefinition(this, 'ApiTaskDefinition', {
      memoryLimitMiB: 512,
      cpu: 256,
    });
    const service = new ecs.FargateService(this, 'Service', { cluster, taskDefinition  });

    const asset = new DockerImageAsset(this, 'Rearc', {
      directory: path.join(__dirname, '/../../'),
    })

    const container = taskDefinition.addContainer("express", {
      image: ecs.ContainerImage.fromDockerImageAsset(asset)
    });

    container.addPortMappings({
      containerPort: 3000,
      protocol: ecs.Protocol.TCP,
      hostPort: 3000,
    });

    const hostedZone = route53.PublicHostedZone.fromPublicHostedZoneAttributes(this,'rootZone',{
      hostedZoneId:HostedZoneID,
      zoneName: 'joshktatum.com'
    });

    const acm_cert = new acm.Certificate(this, "acm-cert-id",{
      domainName:'joshktatum.com',
      subjectAlternativeNames: ['rearc.joshktatum.com'],
      validation:acm.CertificateValidation.fromDns(hostedZone),
    });

    const lb = new elbv2.ApplicationLoadBalancer(this, 'LB', { vpc, internetFacing: true });

    const listener = lb.addListener('Listener', { 
      port: 3000, 
      protocol: elbv2.ApplicationProtocol.HTTPS ,
      open: true,
      certificates: [elbv2.ListenerCertificate.fromArn(acm_cert.certificateArn)]
    });

    new route53.CnameRecord(this, `CnameRecord`, {
      recordName: 'rearc',
      zone: hostedZone,
      domainName: lb.loadBalancerDnsName,
    });

    service.registerLoadBalancerTargets(
      {
        containerName: 'express',
        containerPort: 3000,
        newTargetGroupId: 'ECS',
        listener: ecs.ListenerConfig.applicationListener(listener),
      },
    );
  }
}
