# cloning-repositories

Ce batch permet de cloner et pousser de manière totalement anonymisée un dépôt Git sur **GitHub**.

## Prérequis

Le batch s'appuis sur une version portable de **Git** et **cURL** de manière à être totalement autonome depuis n'importe quel poste sous Windows.
Vous pouvez télécharger les versions portable de ces logiciels depuis les URL suivantes :
* [Git Portable](https://git-scm.com/download/win)
* [cURL](https://curl.se/download.html) 

Décompressez l'intégralité de l'application **Git Portable** dans le dossier `\bin\PortableGit`

Décompressez et déposez uniquement le contenu du dossier **bin** de l'applicaion **cURL** dans le dossier `\bin\cURL`

>Si vous souhaitez utilisez les excutables **Git** et **cURL** déjà disponibles sur votre poste, il vous suffit de changer les chemins d'accès aux programmes dans le batch en vous assurant que chaque programme est disponble dans la variable d'environnement %PATH% de Windows.

## Configuration GitHub

### Token d'accès personnel

Pour pouvoir créer un nouveau dépôt Git sur GitHub, le batch passe par l'API fournit par GitHub pour émettre la demande. Pour authentifier le batch à créer un nouveau dépôt, il a besoin que vous lui fournissiez un jeton d'accès personnel depuis votre compte GitHub. Pour celà rien de plus simple, depuis l'icône de votre compte :
* Cliquez sur l'onglet **Settings**.
* Une fois sur votre profil, cherchez et sélectionnez l'onglet **Developer settings**.
* Cliquez ensuite sur **Personal access tokens**.
* Cliquez sur le bouton **Generate new token**.
* Vous allez devoir choisir les **scopes** sur lequel le token aura accès. Pour les besoins du batch vous pouvez cochez uniquement : **public_repo** et **delete_repo**. N'oubliez pas de laisser une note pour connaître l'utilité du token.
* Ciquez sur le bouton **Generate token**.
* Copiez le token présent sur la page. Celui-ci ne sera visible uniquement qu'à cet instant. Si vous veniez à perdre le token, vous devrez en générer un nouveau.

Dans le batch, remplacez l'élément annoté `<your-github-personal-access-token>` avec le token que vous venez de générer.

### Organisation

Le batch duplique le dépôt Git sur un compte d'organisation. Vous pouvez bien entendu faire de même directement sur un compte GitHub, pour celà il suffit de changer les appels REST à l'API GitHub de cette manière :

`https://api.github.com/repos/<your-organisation-account-name>/` -> `https://api.github.com/<user-account>/repos/`

Dans tout les cas vous devrez indiquer au batch le nom de l'organisation ou du compte utilisateur dans lequel sera créé le dépôt. Dans notre cas, remplacez `<your-organisation-account-name>` avec le nom de votre organisation associé au compte propriétaire où vous avez généré le token d'accès.

### Clé SSH

Dernier point important, Git utilise le protocole **SSH** pour autoriser les manipulations sur le dépôt. Vous devez vous prémunir d'une clé que vous devrez injecter dans votre configuration GitHub. Pour générer une clé SSH et l'utiliser sous GitHub je vous invite à lire l'article suivant : https://techblog.ingeniance.fr/creation-dune-cle-ssh-privee-publique/

Une fois votre clé générée, copiez la clé privé dans un dossier `ssh` à la racine du batch et vérifiez que le nom de la clé correspond bien à celui déclaré dans le batch :

`"%~dp0\bin\PortableGit\cmd\git.exe" -c core.sshCommand="ssh -i ../ssh/id_rsa" push -u --force origin master`
