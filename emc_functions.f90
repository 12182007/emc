! http://www.tek-tips.com/viewthread.cfm?qid=1516435
module emc_functions
    implicit none
contains
function cart2fract(f, cart_coords)
    implicit none
    integer(kind=4), parameter :: size = 3
    real(kind=8), intent(in) :: f(size,size), cart_coords(size)
    real(kind=8) :: f1(size,size), cart2fract(size)
    integer(kind=4) :: IPIV(size), INFO, i, j
    external :: DGETRS, DGESV

    cart2fract = cart_coords
    f1 = f
    IPIV = 0

    call DGETRS( 'T', size, 1, f1, size, IPIV, cart2fract, size, INFO )
    ! call DGESV( 3, 1, cart2fract, 3, IPIV, f1, 3, INFO )
    if (INFO /= 0) then
        write(*,*) "INFO from cart2fract function: ", INFO
        cart2fract = 0.d0
    endif
    ! write(*,*)(cart2fract(j), j=1,3)
    return
end function cart2fract

function pureDEGMV(m, vec, trans)
    implicit none
    integer(kind=4), parameter :: size = 3
    real(kind=8), intent(in) :: m(size,size), vec(size)
    character(len=1), intent(in) :: trans
    real(kind=8) :: pureDEGMV(size)
    external :: DGEMV

    pureDEGMV = 0.d0
    call DGEMV(trans, size, size, 1.d0, m, size, vec, 1, 1.d0, pureDEGMV, 1)
    return
end function pureDEGMV

pure function normal(a, n)
    implicit none
    integer(kind=4), intent(in) :: n
    real(kind=8), intent(in) :: a(n)
    integer(kind=4) :: i
    real(kind=8) :: normal(n), amax

    amax=0.d0
    do i=1, n
       if (DABS(amax) < DABS(a(i))) amax=a(i)
    end do

    normal = a/amax
    return
end function normal

subroutine print_time(iunt)
    implicit none
    integer(kind=4), intent(in) :: iunt
    integer(kind=4) :: today(3), now(3)

    call idate(today)   ! today(1)=day, (2)=month, (3)=year
    call itime(now)     ! now(1)=hour, (2)=minute, (3)=second
    write(iunt,"('Date ',i2.2,'/',i2.2,'/',i4.4,';time ',i2.2,':',i2.2,':',i2.2 )")today(2),today(1),today(3),now
    return
end subroutine print_time

!!!!!!!     UNUSED FUNCTIONS
!!
!
! http://stackoverflow.com/questions/3519959/computing-the-inverse-of-a-matrix-using-lapack-in-c
subroutine inverse(M, n)
    implicit none
    integer(kind=4) :: n, LWORK, ok
    real(kind=8) :: M(n,n)
    integer(kind=4),allocatable :: ipiv(:)
    real(kind=8),allocatable :: WORK(:)
    external DGETRF, DGETRI

    LWORK = n*n
    allocate(WORK(LWORK))
    allocate(ipiv(n+1))

    call DGETRF(n, n, M, n, ipiv, ok)
    if (ok > 0) then
        write(*,*) 'Matrix is singular in: ', ok
        return
    end if
    
    call DGETRI(n, M, n, ipiv, WORK, LWORK, ok)

    if (ok > 0) then
        write(*,*) 'Matrix is singular in: ', ok
        return
    end if

    deallocate(ipiv)
    deallocate(WORK)
    return
end subroutine

function vect2G(f)
    implicit none
    real(kind=8), parameter :: fact = 180.d0/(4.d0*DATAN(1.d0))
    integer(kind=4), parameter :: size = 3
    real(kind=8), intent(in) :: f(size,size)
    real(kind=8) :: l(3), ang(3), vect2G ! vect2G(size,size), 
    integer(kind=4) :: i
    real(kind=8), external :: DDOT

    ! http://theory.cm.utexas.edu/redmine/projects/vtstscripts/repository/entry/pos2cif.pl
    do i=1,3
        l(i) = dsqrt(f(1,i)**2 + f(2,i)**2 + f(3,i)**2)
    end do

    ang(1) = dacos( DDOT(3, f(:,3), 1, f(:,2), 1)/l(2)/l(3) )*fact;
    ang(2) = dacos( DDOT(3, f(:,1), 1, f(:,3), 1)/l(1)/l(3) )*fact;
    ang(3) = dacos( DDOT(3, f(:,1), 1, f(:,2), 1)/l(1)/l(2) )*fact;

    do i=1,3
        write(*,*) l(i), ang(i)
    end do

    return
end function vect2G

end module emc_functions
