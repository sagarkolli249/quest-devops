# A quest in the clouds

### Solution Overiview

This solution deploys the Rearc application to a ECS container runnning on fargate compute. This is fronted by an ALB with a cname of rearc.joshktatum.com.

### links to solution

https://rearc.joshktatum.com:3000/
https://rearc.joshktatum.com:3000/docker (Note: this soluiition is contanerized but as the site notes ECS is a custom orchestrator)
https://rearc.joshktatum.com:3000/secret_word
https://rearc.joshktatum.com:3000/loadbalanced
https://rearc.joshktatum.com:3000/tls

### Setup and deployment

prequisites: Install Docker, and AWS CDK CLI

Congfigure AWS credenetials - either through enviroment variables or use an AWS profile with the --profile argument

Change the Account number in cdk.ts to your target account

Change the Domain name joshktatum.com in cdk/lib/cdk-stack.ts to something you control

run ```cdk bootstrap```

run ```cdk deploy```

your site should be up at https://rearc.domain.name:3000

If you would like to tear down what you have built run ``` cdk destroy ```

### Things to improve

Some main improvement points would be to do less hardcoding around the domain and hosted zone,
 however I wanted to keep the top level domain independent from this project so I can use it for other things.
 Another area of Imporement would be to deploy this Via a CI/CD pipeline instead of using the CDK CLI