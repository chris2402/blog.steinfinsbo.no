---
layout: post
title:  "Hosting static content blogs!"
date:   2024-02-11 20:20:48 +0100
categories: azure hosting
---
# Hosting a static content blog

I've wanted to write a devblog for a while. And recently, during a couple a beers with a friend, I decided attempt doing so by creating with jekyll and deploy it to Azure as a Static Web App.

To make it a *little* bit more interessting, I decided to buy a domain. And ofcourse; I'd like to do it via Azure to get more experience with that platform.

## [Jekyll](https://jekyllrb.com/)
I haven't got any experience with creating blogs, and it probably shows. However, I listened to a podcast where the guest talked about creating a blog in Jekyll. 

But what is it? It is more or less a web-sites compiler from markdown files. There is some configuration needed, and a few syntaxes to learn. But they are fairly easy. With the livereload switch its quite easy to do changes and get feedback on them.

Are you like me and use Windows? Good New! Jekyll has a Windows installer, and is available on winget. And after installation, there is just a few CLI commands to perform to get your blog started.
``` ps
> jekyll new <name-of-blog>
> cd <name-of-blog>
> bundle exec jekyll serve [--livereload | -l] [--open-url | -o]
```

I write my blog entries under the default `_post` directory, where Jekyll finds all my posts. During build, it generates the web-app + some meta-files (`.html`,`.css`, `feed.xml`, `LICENSE` and `README.md`) under `_site`. Ready to be served.

## [Azure Static Web App](https://azure.microsoft.com/en-us/products/app-service/static)
Static Web Apps is an easy way to deploy static websites in Azure. Using the portal, you will be prompted with a wizard to enter a few necessary properties for the Azure resource: Subscription, Name, Region and Hosting plan. It also prompts for a deployment setting, which integrates with GitHub, Azure DevOps or Other (read: do it yourself). 

I selected GitHub, and set the organization, repository and branch. The next step I did not expect: It alows for a Build Preset, which automatically commits a GitHub pipeline YAML specific for your web app framework. 

I selected Jekyll and used the default settings (as I haven't changed anything in Jekyll the config). Review + Create, and the application was deployed in seconds. Heading over to GitHub, I saw the build was already startet. Although it failed on first attempt, as there was some issues with the `Gemfile.lock` for the runtime in the GitHub agent. Deleted the file, recommitted - and it deployed.

### Domain Registrar
I pointed a *blog.* sub-domain in my registrar as `CNAME` entry to the Azure Static Web App. And voila! 

# Conclusion
I skipped a few details, most intentionally - as there are a few quirks I haven't understood. E.g. SSL Certification Setup. But also the fact that I could have done it even simpler with [GitHub](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll) - but that beats the purpose of learning Azure 🤷