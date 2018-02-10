
# Persistent homology with Plotting features (PhPl)
## Collaborator
### Hengrui Luo
The aim and goal of this project is to provide a set of low-level algorithms for complexes with minimal dependencies. Currently, the R package [TDA](https://cran.r-project.org/web/packages/TDA/index.html) developed by CMU team is extremely low in efficiency while the existing [GUDHI(C++)](http://gudhi.gforge.inria.fr/) by INRIA and [JavaPlex(Java)](https://appliedtopology.github.io/javaplex/) by Stanford (for a panoramic review please refer to this nice paper [here](https://arxiv.org/abs/1506.08903)) are efficient enough for application scenarios, they are not easy to modify nor easy to deploy in action according to my own experience manipulating with them. There is also an alternative realization which is especially efficient in Rips complex computation called [Perseus](http://people.maths.ox.ac.uk/nanda/perseus/index.html).

In no way I am demoting any of these wonderful package, yet I still felt a low-level (raw construction) efficient and an easy-to-use (Python3.x)  implement of these algorithms is beneficial.

I have to apologize in advance that my expertise in computer engineering is obviously very limited, therefore I implemented no exception handling or some other 'standard practice' but put a lot of comments and exhibit the functionality as clear as possible.
## Suggestions for Statisticians
 1. For small datasets, 1~20 vertices/distance matrix with dim<=20. 
 I suggest **TDA(R-package)-R** synthesis. 
 I wrote a R interface with extended visualization features [here](https://github.com/hrluo/PHPL/tree/master/TDA-R).
 
 2. For medium datasets, 20~500 vertices/distance matrix with dim<=500. 
 I suggest **Perseus-R** synthesis.
  I wrote a R interface with extended visualization features [here](https://github.com/hrluo/PHPL/tree/master/Perseus-R).
  
 3. For large datasets, >=500 vertices/distance matrix  with dim>=500. 
 I suggest either **Dionysus-Python** OR **JavaPlex-Matlab** synthesis.

## Acknowledgment
The order is purely due to the time I got access to each of following sources, I appreciated all these brilliant people who helped me in building this piece of 
 1. My advisors and friends {Dr.MacEachern,Dr.Peruggia}
 2. A very kind and smart engineer Mr.Elliot who built [PHETS(Python2.7)](https://github.com/eeshugerman/PHETS).


