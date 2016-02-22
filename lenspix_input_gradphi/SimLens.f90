    !Simple program demonstrating how to generate a simulated lensed map
    !AL, Feb 2004; Updated Oct 2007
    program SimLensCMB
    use HealpixObj
    use HealpixVis
    use Random
    use spinalm_tools
    use IniFile
    use AMLUtils
    implicit none
    Type(HealpixInfo)  :: H
    !! ZH modify on !!
    !!Type(HealpixMap)   :: M, GradPhi
    Type(HealpixMap)   :: M, GradPhi, Z
    !! ZH modify off !!
    Type(HealpixPower) :: P
    Type(HealpixAlm)   :: A

    integer            :: nside, lmax
    integer(I_NPIX)    :: npix
    character(LEN=1024)  :: w8name = '../Healpix_2.00/data/'
    character(LEN=1024)  :: file_stem, cls_file, out_file_root, cls_lensed_file
    !! ZH add on !!
    logical :: input_gradphi, random_phi, output_unlensed
    integer :: file_unit
    integer(I_NPIX) :: ipix
    character(LEN=1024)  :: GradPhi_file
    character(LEN=256)   :: out_file_suffix
    complex(SPC), allocatable :: map_gradphi(:)
    !! ZH add off !!
    character(LEN=1024) :: healpixloc
    integer, parameter :: lens_interp =1, lens_exact = 2
    integer :: lens_method = lens_interp
    integer :: mpi_division_method = division_equalrows
    integer ::  interp_method,  rand_seed
    logical :: err, want_pol
    real :: interp_factor
    integer status
#ifdef MPIPIX
    integer i

    call mpi_init(i)
#endif

    Ini_Fail_On_Not_Found = .true.
    call Ini_Open(GetParam(1), 3,err)
    if (err) then
#ifdef MPIPIX
        call mpi_finalize(i)
#endif
        stop 'No ini'
    end if
    nside  = Ini_Read_Int('nside')
    npix = nside2npix(nside)

    lmax   = Ini_Read_Int('lmax')  
    cls_file = Ini_Read_String('cls_file')
    out_file_root = Ini_Read_String('out_file_root')

    !! ZH add on !!
    out_file_suffix    = Ini_Read_String('out_file_suffix')
    input_gradphi = Ini_Read_Logical('input_gradphi', .false.)
    random_phi    = Ini_Read_Logical('random_phi', .true.)
    output_unlensed = Ini_Read_Logical('output_unlensed', .false.)
    if (input_gradphi) then
        GradPhi_file = Ini_Read_String('GradPhi_file')
    endif
    !! ZH add off !!

    lens_method = Ini_Read_Int('lens_method')
    want_pol = Ini_Read_Logical('want_pol')
    rand_seed = Ini_Read_Int('rand_seed')

    interp_method = Ini_read_int('interp_method')

    Ini_Fail_On_Not_Found = .false.


    w8name = Ini_Read_String('w8dir')
    interp_factor=0
    if (lens_method == lens_interp) interp_factor = Ini_Read_Real('interp_factor',3.)
#ifdef MPIPIX
    mpi_division_method = Ini_Read_Int('mpi_division_method',division_balanced);
#endif 

    call Ini_Close

    file_stem =  trim(out_file_root)//'_lmax'//trim(IntToStr(lmax))//'_nside'//trim(IntTOStr(nside))// &
    '_interp'//trim(RealToStr(interp_factor,3))//'_method'//trim(IntToStr(interp_method))//'_'

    if (want_pol) file_stem=trim(file_stem)//'pol_'
    file_stem = trim(file_stem)//trim(IntToStr(lens_method)) 

    !! ZH add on !!
    if (trim(out_file_suffix) .ne. '') then
        file_stem = trim(file_stem)//'_'//trim(out_file_suffix)
    endif
    !! ZH add off !!

    cls_lensed_file  = trim(file_stem)//'.dat'

    call SetIdlePriority()

    if (w8name=='') then
        call get_environment_variable('HEALPIX', healpixloc, status=status)
        if (status==0) then
            w8name = trim(healpixloc)//'/data/'
        end if
    end if

    if (w8name=='') then
        write (*,*) 'Warning: using unit weights as no w8dir found'
        call HealpixInit(H,nside, lmax,.true., w8dir='', method= mpi_division_method) 
    else
        call HealpixInit(H,nside, lmax,.true., w8dir=w8name,method=mpi_division_method) 
    end if 

    if (H%MpiID ==0) then !if we are main thread
        !All but main thread stay in HealpixInit

        call HealpixPower_nullify(P)
        call HealpixAlm_nullify(A)
        call HealpixMap_nullify(GradPhi)
        call HealpixMap_nullify(M)

        call HealpixPower_ReadFromTextFile(P,cls_file,lmax,pol=.true.,dolens = .true.)
        !Reads in unlensed C_l text files as produced by CAMB (or CMBFAST if you aren't doing lensing)

        !! ZH modify on !!
        !!call HealpixAlm_Sim(A, P, rand_seed,HasPhi=.true., dopol = want_pol)
        call HealpixAlm_Sim(A, P, rand_seed, HasPhi=.true., dopol=want_pol, random_phi=random_phi)
        !! ZH modify off !!
        call HealpixAlm2Power(A,P)
        call HealpixPower_Write(P,trim(file_stem)//'_unlensed_simulated.dat')

        !! ZH add on !!
        if (output_unlensed) then
            call HealpixAlm2Map(H, A, Z, npix, DoPhi=.false.)
            call HealpixMap_Write(Z, trim(file_stem)//'_unlensed_map.fits', overwrite=.false.)
            call HealpixMap_Free(Z)
        endif
        !! ZH add off !!

        !! ZH modify on !!
        call HealpixAlm2GradientMap(H,A, GradPhi,npix,'PHI')
        !if (.not. random_phi .and. input_gradphi) then
        !    continue
        !else
        !    call HealpixAlm2GradientMap(H,A, GradPhi,npix,'PHI')
        !endif
        !! ZH modify off !!
    
        !! ZH modify on !!
        allocate(map_gradphi(0:npix-1))
        open(newunit=file_unit, file=trim(gradphi_file), form='binary', status='old', action='read')
        read(file_unit) map_gradphi
        close(file_unit)

        do ipix=0, npix-1
            GradPhi%SpinField(ipix) = GradPhi%SpinField(ipix) + map_gradphi(ipix)
        enddo

        deallocate(map_gradphi)

        !open(newunit=file_unit, file=trim(file_stem)//'_GradPhi.bin', form='binary', status='unknown')
        !write(file_unit) GradPhi%SpinField
        !close(file_unit)
        !! ZH modify off !!

        if (lens_method == lens_exact) then
            call HealpixExactLensedMap_GradPhi(H,A,GradPhi,M)
        else if (lens_method == lens_interp) then
            call HealpixInterpLensedMap_GradPhi(H,A,GradPhi, M, interp_factor, interp_method)
        else
            stop 'unknown lens_method'
        end if

        call HealpixMap2Alm(H,M, A, lmax, dopol = want_pol)
        !This automatically frees previous content of A, and returns new one

        call HealpixAlm2Power(A,P)
        call HealpixAlm_Free(A)
        !Note usually no need to free objects unless memory is short

        call HealpixPower_Write(P,cls_lensed_file)

        !Save map to .fits file
        !call HealpixMap_Write(M, '!lensed_map.fits')

        !! ZH add on !!
        write(*,*) "write to file -"
        write(*,*) trim(file_stem)//'_lensed_map.fits'
        call HealpixMap_Write(M, trim(file_stem)//'_lensed_map.fits', overwrite=.false.)
        !! ZH add off !!

    end if

#ifdef MPIPIX
    call HealpixFree(H)
    call mpi_finalize(i)
#endif

#ifdef DEBUG
    write (*,*) 'End of program'
    pause
#endif
    end program SimLensCMB
