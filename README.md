# Godot JamJar

A batteries-included template for the Godot Engine, designed for game jams.

## Getting Started

There are a few different ways you can start a new project from this template, depending on whether
you want to use GitHub or another provider.

### GitHub.com

Create a new repository from the template [here](https://github.com/new?template_name=godot-jamjar&template_owner=CreatedBySeb),
then clone your repository locally to start working.

### GitHub CLI

Replace `my-project` with the name of your project, then run the following command to create a
project as a private GitHub repo and clone it into your current directory:

```
gh repo create "my-project" --clone --template CreatedBySeb/godot-jamjar --private
```

### Git CLI

Replace the value of `PROJECT_NAME` with the name of your project, then run the following to create
a new local repository based on the template in your current directory:

```
export PROJECT_NAME="my-project"
git clone https://github.com/CreatedBySeb/godot-jamjar.git --depth 1 "$PROJECT_NAME"
cd "$PROJECT_NAME"
rm -rf .git
git init
git add .
git commit -m "New Godot JamJar project"
```

***Note:** You still need to create a remote Git repository and push your local repository to it if
you want to collaborate on your project or back it up remotely.*
