import os
dir_path = os.path.dirname(os.path.realpath(__file__))
print(dir_path)

import numpy as np
import matplotlib.pyplot as plt

import scipy.stats as ss
import scipy.spatial as  ssp

from matplotlib.animation import FuncAnimation
import pandas as pd
import itertools

from functools import reduce

# Read raw data consisting of coordinate pairs.
df = pd.read_csv('test.csv').as_matrix()
# Remove serial number of observations.
df = np.delete(df,0,axis=1)
# Maximal dimension of homologies to be computed.
## Automatically assign as column dim of data.
max_dim = np.shape(df)[1]
def dist(col_array,row_array):
    dist_mat = ssp.distance_matrix(col_array,row_array)
    return dist_mat
def print_matrix(array):    
    print('\n'.join([''.join(['{:.4} \t'.format(item) for item in row]) for row in array]))
# Make a test as below to see if we can get correct distance matrix using prescribed distance.
dist1=dist(df,df)

np.set_printoptions(precision=3)
print_matrix(dist1)

def reduce_list(data):
    uni_list=[]
    for item in data:
        if item not in uni_list:
            uni_list.append(item)
    return uni_list

def VR_simplex(dist_mat,method_param,dim=0):
    
    eps=method_param['eps']
    silent=method_param['silent']
    row_dim = np.shape(dist_mat)[0]
    col_dim = np.shape(dist_mat)[1]
    
    simplex_list=[]
    def check_distance(vertice_list,dist_mat,eps):
        pairwise_flag = True
        vertice_list = set().union(*vertice_list)
        for pair in itertools.combinations(vertice_list,2):
             #print(dist_mat[pair])
            if dist_mat[pair]>eps:
                pairwise_flag=False
        return pairwise_flag
    
    vertice_list = list(range(0,  row_dim) )
    eps=method_param['eps']
        
    if dim==0:
        simplex_list=[{l} for l in vertice_list]
    elif dim>0:
        edge_list = VR_simplex(dist_mat=dist_mat,method_param={'eps':eps,'silent':True},dim=dim-1)
        #print (edge_list)
        #for k in range(dim+1,len(edge_list)+1):
        for k in [dim+1]:
            for k_tuple in itertools.combinations(edge_list, k):
                # if not silent:print("Progress = {0:.{1}f} %".format(perc_prog,2), end="\n", flush=True)
                if check_distance(k_tuple,dist_mat,eps):
                    k_tuple=set().union(*k_tuple)
                    if len(k_tuple)==k:
                        simplex_list.append(k_tuple)
        # Find those marked elements in this dimension yet not in the previous dimension,
        # these are the k-cycles we want to find.
    # reduce these two list to maximal hole and simplex.
    simplex_list=reduce_list(simplex_list)
    if not silent:
        print('VR-threshold   = '+str(eps)+' dim = '+str(dim)+ ' simplex')
        #print('simplex in dim = '+str(dim))
        print(simplex_list)
        #print('\n')
    
    return simplex_list

def VR_hole(dist_mat,method_param,dim=0):
    eps=method_param['eps']
    silent=method_param['silent']
    
    simp_k_plus_1 = VR_simplex(dist_mat=dist_mat,
                     method_param={'eps':eps,'silent':True},
                     dim=dim+1)
    simp_k_plus_1_list=[]
    for n in range(dim+1+1,len(simp_k_plus_1)):
        for y in itertools.combinations(simp_k_plus_1,n):
            y = set().union(*y)
            simp_k_plus_1_list.append(y)
    simp_k = VR_simplex(dist_mat=dist_mat,
                     method_param={'eps':eps,'silent':True},
                     dim=dim)
    
    hole_list=[]
    if dim==0: return []
    for m in range(dim+1,len(simp_k)+1 ):
        for x in itertools.combinations(simp_k,m):
            x = set().union(*x)
            #print(x)
            if x not in simp_k_plus_1_list and x not in simp_k_plus_1 and len(x)==m:
                hole_list.append(x)
    hole_list=reduce_list(hole_list)
    if not silent:
        print('VR-threshold   = '+str(eps)+' dim = '+str(dim)+ ' hole')
        #print('hole in dim = '+str(dim))
        print(hole_list)
        #print('\n')
    return hole_list

epsilon=2.1
simp0 = VR_simplex(dist_mat=dist1,
                     method_param={'eps':epsilon,'silent':True},
                     dim=0)
hole0 = VR_hole(dist_mat=dist1,
                     method_param={'eps':epsilon,'silent':True},
                     dim=0)
simp1 = VR_simplex(dist_mat=dist1,
                     method_param={'eps':epsilon,'silent':True},
                     dim=1)
hole1 = VR_hole(dist_mat=dist1,
                     method_param={'eps':epsilon,'silent':True},
                     dim=1)

simp2 = VR_simplex(dist_mat=dist1,
                     method_param={'eps':epsilon,'silent':True},
                     dim=2)
hole2 = VR_hole(dist_mat=dist1,
                     method_param={'eps':epsilon,'silent':True},
                     dim=2)



def VR_diagram(dist_mat,max_dim=0,method_param=[],eps_list=[]):
    birth_hole=dict()
    death_hole=dict()
    dim_hole=dict()
    ct = 0
    mx = len(eps_list)
    for eps_curr in eps_list:
        print("Progress ", end="")
        print(ct/mx*100,end="%\n")
        ct+=1
        hole_curr_union=[]
        for dim_curr in range(0,max_dim+1):
            simplex_curr = VR_simplex(dist_mat=dist_mat,
                             method_param={'eps':eps_curr,'silent':True},
                             dim=dim_curr)
            hole_curr = VR_hole(dist_mat=dist_mat,
                             method_param={'eps':eps_curr,'silent':True},
                             dim=dim_curr)
            hole_curr_union=hole_curr_union+hole_curr
            for any_hole in hole_curr:
                dim_hole[str(any_hole)]=dim_curr
           # print(eps_curr)
            #print(hole_curr_union)
            for item in hole_curr:
                if str(item) not in birth_hole:
                    birth_hole[str(item)]=eps_curr
        for item in birth_hole:
            item=eval(item)
            if item not in hole_curr_union:
                if str(item) not in death_hole:
                    death_hole[str(item)]=eps_curr
    print(birth_hole)
    print('\n')
    print(death_hole)
                
    return birth_hole,death_hole,dim_hole
steps1 = np.arange(2, 5, .25)
#steps1 = [0,0.1,0.9,1.2,1.9,2.1,2.5]
diag1 = VR_diagram(dist_mat=dist1, max_dim=3, eps_list=steps1)
###Below from

def VR_plot(birth_hole,death_hole,dim_hole):
    ht=0
    plt.plot(0, 0, "o")
    for generator in birth_hole:
        #print(birth_hole[generator])
        #print(death_hole[generator])
        #print("---")
        birth=birth_hole[generator]
        death=death_hole[generator]
        plt.plot([birth, death], [ht, ht], color='k', linestyle='-', linewidth=len(eval(generator)) )
        generator_dim=dim_hole[generator]
        plt.annotate(str(generator)+' dim= '+str(generator_dim), xy=((birth+death)/2, ht))
        ht=ht+1
    plt.show()
    return True

VR_plot(diag1[0],diag1[1],diag1[2])
#plt.scatter(df)
#plt.show()
###minimal example
np.random.seed(180206)
df2=[]
x2 = list(range(1, 10))
for obs in x2:
    y2 = obs*.25 + float( np.random.normal(0,1000, 1) )
    df2.append([obs,y2])
    plt.scatter(obs,y2)
plt.show()

dist2=dist(df2,df2)
print_matrix(dist2)
steps2 = np.arange(0, 10, .1)
diag2 = VR_diagram(dist_mat=dist2, max_dim=3, eps_list=steps2)
VR_plot(diag2[0],diag2[1],diag2[2])
