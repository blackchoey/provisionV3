@maxLength(20)
@minLength(4)
@description('Used to generate names for all resources in this file')
param resourceBaseName string

param botAadAppClientId string

@secure()
param botAadAppClientSecret string

param botServiceName string = resourceBaseName
param botServiceSku string = 'F0'
param botDisplayName string = resourceBaseName
param serverfarmsName string = '${resourceBaseName}bot'
param webAppSKU string = 'F1'
param webAppName string = '${resourceBaseName}bot'
param location string = resourceGroup().location

param m365ClientId string = ''
@secure()
param m365ClientSecret string = ''
param m365TenantId string = ''
param m365OauthAuthorityHost string = ''

// Compute resources for your Web App
resource serverfarm 'Microsoft.Web/serverfarms@2021-02-01' = {
  kind: 'app'
  location: location
  name: serverfarmsName
  sku: {
    name: webAppSKU
  }
}

// Web App that hosts your bot
resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  kind: 'app'
  location: location
  name: webAppName
  properties: {
    serverFarmId: serverfarm.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14' // Set NodeJS version to 14.x for your site
        }
        {
          name: 'SCM_SCRIPT_GENERATOR_ARGS'
          value: '--node' // Register as node server
        }
        {
          name: 'RUNNING_ON_AZURE'
          value: '1'
        }
        {
          name: 'BOT_ID'
          value: botAadAppClientId
        }
        {
          name: 'BOT_PASSWORD'
          value: botAadAppClientSecret
        }
        // Following app settings are reserved for SSO. The values will be empty if you don't have SSO enabled. You can use Teams Toolkit to add SSO feature to your bot.
        {
          name: 'M365_CLIENT_ID'
          value: m365ClientId
        }
        {
          name: 'M365_CLIENT_SECRET'
          value: m365ClientSecret
        }
        {
          name: 'M365_TENANT_ID'
          value: m365TenantId
        }
        {
          name: 'M365_OAUTH_AUTHORITY_HOST'
          value: m365OauthAuthorityHost
        }
      ]
      ftpsState: 'FtpsOnly'
    }
  }
}

// Register your web service as a bot with the Bot Framework
module azureBotRegistration 'botregistration/azurebot.bicep' = {
  name: 'Azure Bot registration'
  params: {
    resourceBaseName: resourceBaseName
    botAadAppClientId: botAadAppClientId
    botAppDomain: webApp.properties.defaultHostName
  }
}

// The output will be persisted in .fx/.env.{envName}
output CLOUD_BOT_RESOURCE_ID string = webApp.id
output CLOUD_BOT_DOMAIN string = webApp.properties.defaultHostName
