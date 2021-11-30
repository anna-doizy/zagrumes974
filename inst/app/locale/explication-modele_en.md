Nous vous proposons ici de présenter les résultats d'un **modèle de développement d’une épidémie de HBL dans un parcellaire d'agrumes fictif**. 

### Mise en place et définition

Les parcelles d'agrumes ont des surfaces variant entre 0 et 7 hectares.
Les parcelles les plus éloignées les unes des autres le sont d’environ 5 kilomètres. 
***[taille totale du carré ?]***

Nous définissons l'**état sanitaire** d'une parcelle de la manière suivante :

- **saine** : le HLB n'est pas présent dans la parcelle (vert)
- **infectée** : le HLB est présent dans la parcelle, mais ne diffuse pas encore aux autres parcelles alentour (orange)
- **infectieuse** : la maladie présente dans la parcelle se transmet aux parcelles alentour (rouge)
- **arrachée** : la parcelle a été arrachée (noir)

NB : Un arbre infecté finira par mourir que ce soit en plusieurs mois ou quelques années. 
Ici les temps de simulations sont trop courts pour que la possibilité d’une mort autre que par arrachage soit constatée.


### Initialisation du modèle

Une parcelle est infectée par le HLB au jour 1 ***(ou 0 ?)***.


### Evolution du modèle

Tous les jours, chaque parcelle contenant un arbre malade va en contaminer d'autres. 

- Le paramètre **R0** ([nombre de reproduction de base](https://fr.wikipedia.org/wiki/Nombre_de_reproduction_de_base)) permet de fixer combien de parcelles sont contaminées en moyenne par un arbre malade. Nous avons choisi `R0 = 1` par défaut.

- Le paramètre **Seuil de transmission** permet de moduler la distance maximale de transmission de la maladie par un arbre infecté. Par défaut, il n'y a `pas de distance limite` de transmission.

- Le paramètre **Fréquence d'arrachage** représente l'effort de la gestion de la maladie. Ces mesures sont effectuées en réalité soit par les services de l’état, soit par l’agriculteur. Par défaut, une parcelle contenant un arbre infecté est arrachée aléatoirement tous les `30 jours`.

- Le paramètre **Durée de la simulation** fixe la fin de la simulation. Par défaut, elle s'arrête au bout de `100 jours`.


### Représentation des résultats du modèle

- Le premier graphique montre l'évolution de l'état sanitaire des ***(combien ?)*** parcelles au cours de la simulation.

- En-dessous, vous pouvez observer la carte du parcellaire qui évolue au fil des jours.
  Chaque point représente une parcelle d'agrumes.


> Amusez-vous à jouer sur quelques valeurs des paramètres du modèle pour voir comment cela impacte la propagation de la maladie !
