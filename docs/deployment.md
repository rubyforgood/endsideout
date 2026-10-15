# Deployment

## Configuring AWS Instance
Kamal's deployment model includes a proxy that runs on the instance and handles the app via a blue/green deployment model.
During deployment the current version of the app is running while the new version is being deployed.
During the deployment process, the proxy runs status checks on the new version of the app to ensure it is healthy before switching traffic over to it. 
This approach means that during deployment, two versions of the app are running at the same time, which can cause memory issues if the instance is too small.
When choosing an instance you either need to ensure the instance has enough memory to run two versions of the app at the same time, or you need to add swap space to the instance to ensure it doesn't run out of memory during deployment.
If you choose to add swap space, you need to ensure the instance has a big enough volume to add swap space. 
*AWS defaults to 8GB volumes, which is realistically not enough to add swap space (or honestly to not run into other issues).* Be sure that you choose a volume size that is big enough to add swap space. 20 GB is a good minimum.

## Secrets and Credentials
### Rails Credentials
The encryption keys for Rails credentials are stored in AWS Secrets Manager. 
In order to deploy you need to create a key file in the config/credentials folder such as `config/credentials/staging.key` with the value from secrets manager.
*These files should remain gitignored and not be checked into source control.*

### SSH Keys
Kamal uses SSH to connect to the instance and deploy the application. This key is stored in AWS Secrets Manager and needs to be downloaded and placed in the `~/.ssh/` folder with permissions set to 600.
Note you should use the same file name referenced for the key in the environment specific deployment configuration. For example [deploy.staging.yml](../config/deploy.staging.yml)

## AWS CLI
You need to be logged into the AWS CLI to deploy. You can use `aws configure` to set up your credentials. 
You can make a named profile for this AWS account if you have multiple AWS accounts using `aws configure --profile your_profile_name`.
To ensure that kamal uses the correct profile, run EXPORT AWS_PROFILE=your_profile_name to set the profile for the current terminal session.

## Important Gotchas
- We have configured kamal to use explicit deploy targets. Therefore you always need to specify the target environment when using any kamal command. For example, `bin/kamal deploy -d staging`
- Kamal only deploys committed code. If you have uncommitted changes, they will not be deployed.