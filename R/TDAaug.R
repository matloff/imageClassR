
# data augmentation for TDAsweep files; done in lieu of applying data aug to
# the raw data

# advantage: one can experiment with different aug configurations
# without having to recalculate TDAsweep each time

# disadvantage: only rotations and translations (shifts) are covered;
# augment the raw data if other types of aug are needed


# arguments:

#    tdaImg: image in TDA format; square, rows/columns only
#    rot: amount of rotation, counterclockwise, limited to 

