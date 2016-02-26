import numpy as py

__all__ = ['lenspy']

class setup_lenspix_run(object):

    def __init__(self, workspace, Cls_file, nside=8192, lmax=10000, nsims=1, output_prefix='lensed_cmb', 
                 lens_method=1, pol=False, seed_init=0, output_unlensed=False, output_phimap=False):
        self.workspace = workspace
