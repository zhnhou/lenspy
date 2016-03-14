import numpy as py

__all__ = ['lenspy']

class setup_lenspix_run(object):

    def __init__(self, workspace, Cls_file, nsims=500, nside=8192, lmax=10000, nsims=1, output_prefix='lensed_cmb', 
                 lens_method=1, pol=False, seed_init=0, output_unlensed=False, output_phimap=False):
        self.workspace = workspace
        self.cls_file  = Cls_file
        self.nsims     = nsims
        self.nside     = nside
        self.lmax      = lmax
        self.nsims     = nsims
        self.output_prefix = output_prefix
        self.lens_method = lens_method
        self.has_pol = pol
        self.seed_init = seed_init
        self.output_unlensed = output_unlensed
        self.output_phimap = output_phimap

    def create_ini(self):

