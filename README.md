# Azure Hacking

## Iniitial Access

### Background - Azure vs ASDK

Microsoft has an on-premise Azure environment called Azure Stack which is meant primarily for enterprise usage. There is also a version called Azure Stack Development Kit (ASDK) which is free. 

Main Differences: 
- Scalability
  - ASDK runs on a single instance with limited resources and all of its roles run as separate VMs handled by Hyper-V. This causes some internal architectural differences.
- ASDK doesn’t run the latest software as Azure does, but is a couple of versions behind.
- Compared to Azure, ASDK has a very limited number of features.

#### Azure Stack Overview
![Azure Stack Overview](https://research.checkpoint.com/wp-content/uploads/2020/01/azure2.png)

##### [Infrastructure Roles](https://docs.microsoft.com/en-us/azure-stack/asdk/asdk-architecture?view=azs-2005) :
- AzS-ACS01 -	Azure Stack storage services.
- AzS-ADFS01 -	Active Directory Federation Services (ADFS).
- AzS-CA01 -	Certificate authority services for Azure Stack role services.
- AzS-DC01 -	Active Directory, DNS, and DHCP services for Microsoft Azure Stack.
- AzS-ERCS01 -	Emergency Recovery Console VM.
- AzS-GWY01 -	Edge gateway services such as VPN site-to-site connections for tenant networks.
- AzS-NC01 -	Network Controller, which manages Azure Stack network services.
- AzS-SLB01 -	Load-balancing multiplexer services in Azure Stack for both tenants and Azure Stack infrastructure services.
- AzS-SQL01 -	Internal data store for Azure Stack infrastructure roles.
- AzS-WAS01 -	Azure Stack administrator portal and Azure Resource Manager services.
- AzS-WASP01 -	Azure Stack user (tenant) portal and Azure Resource Manager services.
- AzS-XRP01 -	Infrastructure management controller for Microsoft Azure Stack, including the Compute, Network, and Storage resource providers.
- AzS-SRNG01 -	Support Ring VM hosting the log collection service for Azure Stack.

Main Virtual Machines:

* ARM Layer: AzS-WAS01, AzS-WASP01
* RP Layer + Infrastructure Control Layer: AzS-XRP01

Issues: 

Service Fabric Explorer is a web tool pre-installed in the machine that takes the role of the RP and Infrastructure Control Layer. This enables us to view the internal services which are built as Service Fabric Applications, which is located in the RP layer. Some of the URLs of the services from the SFE don't require authentication, which can lead to vulnerabilities in the entire stack. 

### Vulnerabilities

1. [CVE-2019-1234](https://nvd.nist.gov/vuln/detail/CVE-2019-1234) - spoofing

If exploited, the issue would have enabled a remote hacker to unauthorizedly access screenshots and sensitive information of any virtual machine running on Azure infrastructure — it doesn't matter if they're running on a shared, dedicated or isolated virtual machines.

2. [CVE-2019-1372](https://nvd.nist.gov/vuln/detail/CVE-2019-1372#:~:text=An%20remote%20code%20execution%20vulnerability,the%20context%20of%20NT%20AUTHORITY%5C) - remote code execution

An attacker who successfully exploited this vulnerability could allow an unprivileged function run by the user to execute code in the context of NT AUTHORITY\system thereby escaping the Sandbox.

### Recon (Outsider) - https://o365blog.com/aadkillchain/

### Intrusion - Execution

#### Password Spraying

#### User Enumeration

#### 

#### Phishing - Azure App

1. Background - requires victim to own a web application hosted by an Azure tenant. 

2. Spear phishing campaign

3. The link in the email directs the user to the attacker-controlled website (e.g., https://myapp.malicious.com) which seamlessly redirects the victim to Microsoft’s login page. The authentication flow is handled entirely by Microsoft, so using multi-factor authentication isn’t a viable mitigation.

Once the user logs into their O365 instance, a token will be generated for the malicious app and the user will be prompted to authorize and give it the permissions it needs. 

![token](https://blogvaronis2.wpengine.com/wp-content/uploads/2020/03/3.png)

4. On the attacker’s side, here are the MS Graph API permissions that are being requested:

![Permissions Requested by Malicious App](https://blogvaronis2.wpengine.com/wp-content/uploads/2020/03/4.png)

The attacker has control over the application’s name and the icon. The URL is a valid Microsoft URL and the certificate is valid.

Under the application’s name, however, is the name of the attacker’s tenant and a warning message, neither of which can be hidden. An attacker’s hope is that a user will be in a rush, see the familiar icon, and move through this screen as quickly and thoughtlessly as they’d move through a terms of service notice.

By clicking “Accept”, the victim grants the aplication the permissions on behalf of their user—i.e., the application can read the victim’s emails and access any files they have access to.

This step is the only one that requires the victim’s consent — from this point forward, the attacker has complete control over the user’s account and resources.

After granting consent to the application, the victim will be redirected to a website of our choice. A nice trick can be to map the user’s recent file access and redirect them to an internal SharePoint document so the redirection is less suspicious.

### Post Intrusion - Persistance forward

1. Reconnaissance (enumerating users, groups, objects in the user’s 365 tenant)

2. Spear phishing (internal-to-internal)

3. Stealing files and emails from Office 365

4. API metadata: 
  - gain access to metadata for every single user in the organization
  - shows the victim’s calendar events. Can also set up meetings on their behalf, view existing meetings, and even free up time in their day by deleting meetings they set in the future.
  - see any file the user accessed in OneDrive or SharePoint. You can also download or modify files (malicious macros for persistence).
  - When accessing a file via this API, Azure generates a unique link. This link is accessible by anyone from any location—even if the organization does not allow anonymous sharing links for normal 365 users.
  - complete access to our victim’s email. We can see the recipients of any message, filter by high priority emails, send emails (i.e., spear phish other users), and more.
  - By reading the user’s emails, you can identify the most common and vulnerable contacts, send internal spear-phishing emails that come from our victim, and infect his peers. You can also use the victim’s email account to exfiltrate data that you find in 365.
  - Microsoft also provides insights about the victim’s peers using the API. The peer data could be used to pinpoint other users that the victim had the most interaction with
  - modify the user’s files with the right permissions. (potential: One option is to turn the malicious Azure app into ransomware that remotely encrypts files that the user has access to on SharePoint and OneDrive)

5. [AWS Lambda](https://danielgrzelak.com/backdooring-an-aws-account-da007d36f8f9)

6. [Azure Persistance](https://blog.netspi.com/maintaining-azure-persistence-via-automation-accounts/) - Adds an Automation Account with excessive privileges that can be used to add new accounts (with Subscription Owner permissions) to AzureAD via a single POST request.

  Process
  - Create a new Automation Account
  - Import a new runbook that creates an AzureAD user with Owner permissions for the subscription*
  - Sample runbook for this Blog located here – https://github.com/NetSPI/MicroBurst
  - Add the AzureAD module to the Automation account
  - Update the Azure Automation Modules
  - Assign “User Administrator” and “Subscription Owner” rights to the automation account
  - Add a webhook to the runbook
  - Eventually lose your access…
  - Trigger the webhook with a post request to create the new user


### Resources

* https://thehackernews.com/2020/01/microsoft-azure-vulnerabilities.html
* https://medium.com/@kamran.bilgrami/ethical-hacking-lessons-building-free-active-directory-lab-in-azure-6c67a7eddd7f
* https://research.checkpoint.com/2020/remote-cloud-execution-critical-vulnerabilities-in-azure-cloud-infrastructure-part-i/
* https://research.checkpoint.com/2020/remote-cloud-execution-critical-vulnerabilities-in-azure-cloud-infrastructure-part-ii/
* https://rhinosecuritylabs.com/cloud-security/common-azure-security-vulnerabilities/
* https://portswigger.net/daily-swig/spotlight-shone-on-microsoft-azure-vulnerability
* https://www.darkreading.com/cloud/how-attackers-could-use-azure-apps-to-sneak-into-microsoft-365/d/d-id/1337399
* https://www.youtube.com/watch?v=JEIR5oGCwdg
* https://danielzstinson.wordpress.com/cloud-computing-may-not-be-as-secure-as-you-would-like-to-believevulnerabilities-in-azure-part-2/
* https://www.darkreading.com/cloud/how-attackers-could-use-azure-apps-to-sneak-into-microsoft-365/d/d-id/1337399
* https://docs.microsoft.com/en-us/azure/security-center/security-center-alerts-overview
* https://docs.microsoft.com/en-us/azure/security/fundamentals/threat-detection
* https://www.varonis.com/blog/using-malicious-azure-apps-to-infiltrate-a-microsoft-365-tenant/
* https://www.exfiltrated.com/research/HackingTheClouds.pdf
* https://danielgrzelak.com/backdooring-an-aws-account-da007d36f8f9
* https://cyberx.tech/hacking-lab/
* https://blog.netspi.com/maintaining-azure-persistence-via-automation-accounts/

# Office 365 Hacking

## Vulnerabilities

1. [SAML](https://www.pindrop.com/blog/office-365-bug-allowed-attackers-to-login-to-virtually-any-account/) - A vulnerability in Microsoft Office 365 SAML Service Provider implementation allowed for cross domain authentication bypass affecting all federated domains. An attacker exploiting this vulnerability could gain unrestricted access to a victim’s Office 365 account, including access to their email, files stored in OneDrive etc.

## Resources

* https://www.coreview.com/blog/office-365-vulnerabilities-hacks-and-attacks/
* https://www.pindrop.com/blog/office-365-bug-allowed-attackers-to-login-to-virtually-any-account/
* https://www.fireeye.com/blog/threat-research/2020/07/insights-into-office-365-attacks-and-how-managed-defense-investigates.html
* https://www.darkreading.com/cloud/how-attackers-could-use-azure-apps-to-sneak-into-microsoft-365/d/d-id/1337399
* https://o365blog.com/aadkillchain/
