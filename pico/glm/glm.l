(symbols 'glm 'pico)

(load "@lib/math.l")

(scl 15)

(default
  f*
    '(@
      (let X (next)
        (while (next)
          (setq X (*/ X @ 1.0)))))
  f/
    '(@
      (let X (next)
        (while (next)
          (setq X (*/ 1.0 X @))))))

# use math lib for trig


(de mat4-sca (V)
  (list
    (car V) 0.0      0.0       0.0
    0.0     (cadr V) 0.0       0.0
    0.0     0.0      (caddr V) 0.0
    0.0     0.0      0.0       1.0))

        
(de mat4-tra (V)
  (list
    1.0     0.0      0.0       0.0
    0.0     1.0      0.0       0.0
    0.0     0.0      1.0       0.0
    (car V) (cadr V) (caddr V) 1.0))


(de mat4-id ()
  (list
    1.0 0.0 0.0 0.0
    0.0 1.0 0.0 0.0
    0.0 0.0 1.0 0.0
    0.0 0.0 0.0 1.0))

        
(de mat4-rx (F)
  (let (C (native "@" "cos" 1.0 (cons F 1.0))
        S (native "@" "sin" 1.0 (cons F 1.0)))
    (list
      1.0  0.0    0.0  0.0
      0.0  C      S    0.0
      0.0  (- S)  C    0.0
      0.0  0.0    0.0  1.0)))

(de mat4-ry (F)
  (let (C (native "@" "cos" 1.0 (cons F 1.0))
        S (native "@" "sin" 1.0 (cons F 1.0)))
    (list
      C    0.0  (- S)  0.0
      0.0  1.0  0.0    0.0
      S    0.0  C      0.0
      0.0  0.0  0.0    1.0)))


(de mat4-rz (F)
  (let (C (native "@" "cos" 1.0 (cons F 1.0))
        S (native "@" "sin" 1.0 (cons F 1.0)))
    (list
      C      S    0.0  0.0
      (- S)  C    0.0  0.0
      0.0    0.0  1.0  0.0
      0.0    0.0  0.0  1.0)))

        
# Untested
(de pers (Fov-Y A N F)
  (let Thfy
        (*/
          1.0
          1.0
          (native "@" "tan" 1.0
            (cons (*/ Fov-Y 0.5 1.0) 1.0)))
    (list
      (*/ (*/ 1.0 1.0 A) Thfy 1.0)
      0.0
      0.0
      0.0
      0.0
      (*/ 1.0 1.0 Thfy)
      0.0
      0.0
      0.0
      0.0
      (*/ 1.0 F (- N F))
      -1.0
      0.0
      0.0
      (*/ 1.0
        (- (*/ F N 1.0))
        (- F N))
      0.0)))


(de mat4-ortho (L R B Top N F)
  (list
    (*/ 1.0 2.0 (- R L))
    0.0
    0.0
    0.0

    0.0
    (*/ 1.0 2.0 (- Top B))
    0.0
    0.0

    0.0
    0.0
    (*/ 1.0 -2.0 (- F N))
    0.0

    (- (*/ 1.0 (+ R   L) (- R   L)))
    (- (*/ 1.0 (+ Top B) (- Top B)))
    (- (*/ 1.0 (+ F   N) (- F   N)))
    1.0))
           

(de mat4-inv (M)
  (let ((M11 M21 M31 M41
         M12 M22 M32 M42
         M13 M23 M33 M43
         M14 M24 M34 M44) M
        I0   (+    (f* M22 M33 M44)  (- (f* M22 M43 M34)) (- (f* M23 M32 M44))    (f* M23 M42 M34)     (f* M24 M32 M43)  (- (f* M24 M42 M33)))
        I4   (+ (- (f* M12 M33 M44))    (f* M12 M43 M34)     (f* M13 M32 M44)  (- (f* M13 M42 M34)) (- (f* M14 M32 M43))    (f* M14 M42 M33))
        I8   (+    (f* M12 M23 M44)  (- (f* M12 M43 M24)) (- (f* M13 M22 M44))    (f* M13 M42 M24)     (f* M14 M22 M43)  (- (f* M14 M42 M23)))
        I12  (+ (- (f* M12 M23 M34))    (f* M12 M33 M24)     (f* M13 M22 M34)  (- (f* M13 M32 M24)) (- (f* M14 M22 M33))    (f* M14 M32 M23))

        I1   (+ (- (f* M21 M33 M44))    (f* M21 M43 M34)     (f* M23 M31 M44)  (- (f* M23 M41 M34)) (- (f* M24 M31 M43))    (f* M24 M41 M33))
        I5   (+ (- (f* M11 M33 M44)     (f* M11 M43 M34)     (f* M13 M31 M44))    (f* M13 M41 M34)     (f* M14 M31 M43)  (- (f* M14 M41 M33)))
        I9   (+ (- (f* M11 M23 M44))    (f* M11 M43 M24)     (f* M13 M21 M44)  (- (f* M13 M41 M24)) (- (f* M14 M21 M43))    (f* M14 M41 M23))
        I13  (+    (f* M11 M23 M34)  (- (f* M11 M33 M24)) (- (f* M13 M21 M34))    (f* M13 M31 M24)     (f* M14 M21 M33)  (- (f* M14 M31 M23)))

        I2   (+    (f* M21 M32 M44)  (- (f* M21 M42 M34)) (- (f* M22 M31 M44))    (f* M22 M41 M34)     (f* M24 M31 M42)  (- (f* M24 M41 M32)))
        I6   (+ (- (f* M11 M32 M44))    (f* M11 M42 M34)     (f* M12 M31 M44)  (- (f* M12 M41 M34)) (- (f* M14 M31 M42))    (f* M14 M41 M32))
        I10  (+    (f* M11 M22 M44)  (- (f* M11 M42 M24)) (- (f* M12 M21 M44))    (f* M12 M41 M24)     (f* M14 M21 M42)  (- (f* M14 M41 M22)))
        I14  (+ (- (f* M11 M22 M34))    (f* M11 M32 M24)     (f* M12 M21 M34)  (- (f* M12 M31 M24)) (- (f* M14 M21 M32))    (f* M14 M31 M22))

        I3   (+ (- (f* M21 M32 M43))    (f* M21 M42 M33)     (f* M22 M31 M43)  (- (f* M22 M41 M33)) (- (f* M23 M31 M42))    (f* M23 M41 M32))
        I7   (+    (f* M11 M32 M43)  (- (f* M11 M42 M33)) (- (f* M12 M31 M43))    (f* M12 M41 M33)     (f* M13 M31 M42)  (- (f* M13 M41 M32)))
        I11  (+ (- (f* M11 M22 M43))    (f* M11 M42 M23)     (f* M12 M21 M43)  (- (f* M12 M41 M23)) (- (f* M13 M21 M42))    (f* M13 M41 M22))
        I15  (+    (f* M11 M22 M33)  (- (f* M11 M32 M23)) (- (f* M12 M21 M33))    (f* M12 M31 M23)     (f* M13 M21 M32)  (- (f* M13 M31 M22)))

        DI (f/ 1.0 (+ (f* M11 I0) (f* M21 I4) (f* M31 I8) (f* M41 I12))))

    (list
      (f* I0  DI)
      (f* I1  DI)
      (f* I2  DI)
      (f* I3  DI)
      (f* I4  DI)
      (f* I5  DI)
      (f* I6  DI)
      (f* I7  DI)
      (f* I8  DI)
      (f* I9  DI)
      (f* I10 DI)
      (f* I11 DI)
      (f* I12 DI)
      (f* I13 DI)
      (f* I14 DI)
      (f* I15 DI))))


(de mat4-mul (A B)
  (let ((A1  A2  A3  A4
         A5  A6  A7  A8 
         A9  A10 A11 A12 
         A13 A14 A15 A16) A
        (B1  B2  B3  B4
         B5  B6  B7  B8 
         B9  B10 B11 B12 
         B13 B14 B15 B16) B)

    (list
      (+ (*/ A1 B1  1.0) (*/ A5 B2  1.0) (*/ A9  B3  1.0) (*/ A13 B4  1.0))
      (+ (*/ A2 B1  1.0) (*/ A6 B2  1.0) (*/ A10 B3  1.0) (*/ A14 B4  1.0))
      (+ (*/ A3 B1  1.0) (*/ A7 B2  1.0) (*/ A11 B3  1.0) (*/ A15 B4  1.0))
      (+ (*/ A4 B1  1.0) (*/ A8 B2  1.0) (*/ A12 B3  1.0) (*/ A16 B4  1.0))

      (+ (*/ A1 B5  1.0) (*/ A5 B6  1.0) (*/ A9  B7  1.0) (*/ A13 B8  1.0))
      (+ (*/ A2 B5  1.0) (*/ A6 B6  1.0) (*/ A10 B7  1.0) (*/ A14 B8  1.0))
      (+ (*/ A3 B5  1.0) (*/ A7 B6  1.0) (*/ A11 B7  1.0) (*/ A15 B8  1.0))
      (+ (*/ A4 B5  1.0) (*/ A8 B6  1.0) (*/ A12 B7  1.0) (*/ A16 B8  1.0))

      (+ (*/ A1 B9  1.0) (*/ A5 B10 1.0) (*/ A9  B11 1.0) (*/ A13 B12 1.0))
      (+ (*/ A2 B9  1.0) (*/ A6 B10 1.0) (*/ A10 B11 1.0) (*/ A14 B12 1.0))
      (+ (*/ A3 B9  1.0) (*/ A7 B10 1.0) (*/ A11 B11 1.0) (*/ A15 B12 1.0))
      (+ (*/ A4 B9  1.0) (*/ A8 B10 1.0) (*/ A12 B11 1.0) (*/ A16 B12 1.0))

      (+ (*/ A1 B13 1.0) (*/ A5 B14 1.0) (*/ A9  B15 1.0) (*/ A13 B16 1.0))
      (+ (*/ A2 B13 1.0) (*/ A6 B14 1.0) (*/ A10 B15 1.0) (*/ A14 B16 1.0))
      (+ (*/ A3 B13 1.0) (*/ A7 B14 1.0) (*/ A11 B15 1.0) (*/ A15 B16 1.0))
      (+ (*/ A4 B13 1.0) (*/ A8 B14 1.0) (*/ A12 B15 1.0) (*/ A16 B16 1.0)))))


(de mat4-mul@ @
  (let A (next)
    (while (next)
      (setq A (mat4-mul A @)))
    A))
          
          
(de mat4-mul-v4 (M V)
  (let ((M1  M2  M3  M4
         M5  M6  M7  M8 
         M9  M10 M11 M12 
         M13 M14 M15 M16) M
        (X Y Z W) V)
    (list
      (+ (*/ M1 X 1.0) (*/ M5 Y 1.0) (*/ M9  Z 1.0) (*/ M13 W 1.0))
      (+ (*/ M2 X 1.0) (*/ M6 Y 1.0) (*/ M10 Z 1.0) (*/ M14 W 1.0))
      (+ (*/ M3 X 1.0) (*/ M7 Y 1.0) (*/ M11 Z 1.0) (*/ M15 W 1.0))
      (+ (*/ M4 X 1.0) (*/ M8 Y 1.0) (*/ M12 Z 1.0) (*/ M16 W 1.0)))))

# Refactor to pass in Win and View
# X Y W H = Viewport
(de unproj (Win ModelView Proj X Y W H)
  # v3, m4, m4, v4 (x,y,w,h)
      
  (let (V
        (list
          (-
            (f* 2.0
              (f/
                (-
                  (get Win 1)
                  X)
                W))
            1.0)
          (-
            (f* 2.0
              (f/
                (-
                  (get Win 2)
                  Y)
                H))
            1.0)
          (-
            (f* 2.0 (get Win 3))
            1.0)
          1.0)
        Mat (mat4-inv (mat4-mul Proj ModelView))
        (X Y Z W) (mat4-mul-v4 Mat V))

    # W always 1.0 for ortho
    (list
      X
      Y
      Z
      W)))


(de mat4-transpose (M)
  (let ((M1  M2  M3  M4
         M5  M6  M7  M8
         M9  M10 M11 M12
         M13 M14 M15 M16) M)
    (list
      M1 M5 M9  M13
      M2 M6 M10 M14
      M3 M7 M11 M15
      M4 M8 M12 M16)))


#########
# Vectors
#
# * twizzling functions
#
# * alt: properties for components -> faster but larger
#   * typically lots of vectors so optimize for space

###########
# Vector 2D

(class +Vec2)
(dm T @
  (=: vec
    (let A (rest)
      (cond
        # check for Y

        # pass X Y -> (X Y)
        ((num?
          (car (cdr A)))
          (cons (car A) @))

        # pass (X . Y) -> ((X . Y))
        ((num?
          (cdr (car A)))
          (cons (caar A) @))

        # pass (X Y) -> ((X Y))
        ((num?
          (car (cdr (car A))))
          (cons (caar A) @))

        # pass +Vec2
        ((isa '(+Vec2) (car A))
          (copy (ptr> @)))

        # -> (-Inf . -Inf)
        (T (cons))))))


(dm pr> ()
  (prinl
    (text "((X Y) @1 @2)"
      (format (car (: vec)) *Scl)
      (format (cdr (: vec)) *Scl))))

(dm fmt> () # str>
  (text "@1 @2"
    (format (car (: vec)) *Scl)
    (format (cdr (: vec)) *Scl)))

(dm x> @ (if (next) (set (: vec) @) (car (: vec))))
(dm y> @ (if (next) (con (: vec) @) (cdr (: vec))))

# ptr (formerly *-vec)
(dm ptr> @
  (if (next) (=: vec @) (: vec)))

(dm => (V) (= (ptr> V) (ptr> This)))
(dm ==> (V) (== (ptr> V) (ptr> This)))

(dm xy> @
  (if (next)
      (prog
        (x> This @)
        (y> This (next)))
      (copy (: vec))))

####

(dm +> (B)
  (new '(+Vec2)
    (+ (x> This) (x> B))
    (+ (y> This) (y> B))))

(dm +xyz> (X Y)
  (new '(+Vec2)
    (+ (x> This) X)
    (+ (y> This) Y)))

(dm +n> (N)
  (new '(+Vec2)
    (+ (x> This) N)
    (+ (y> This) N)))

(dm -> (B)
  (new '(+Vec2)
    (- (x> This) (x> B))
    (- (y> This) (y> B))))

(dm -xyz> (X Y)
  (new '(+Vec2)
    (- (x> This) X)
    (- (y> This) Y)))

(dm -n> (N)
  (new '(+Vec2)
    (- (x> This) N)
    (- (y> This) N)))

# do arithmetic...

# length

(dm mag> () # or mag
  (sqrt
    (+
      (pow (x> This) 2.0)
      (pow (y> This) 2.0))
    1.0))

(dm dist> (B)
  (sqrt
    (+
      (pow (- (x> This) (x> B)) 2.0)
      (pow (- (y> This) (y> B)) 2.0))
    1.0))

(dm norm> ()
  (let L (mag> This)
    (new '(+Vec2)
      (f/ (x> This) L)
      (f/ (y> This) L))))

###########
# Vector 3D

(class +Vec3)

# TODO: Fix
(when NIL
  (dm T @
    (=: vec
      (let A (rest)
        (cond
          # check for Y

          # pass X Y -> (X Y Z)
          ((num? (car (cdr A)))
            (cons (car A)
              (cons @
                (cddr A))))

          # pass (X Y Z) -> ((X Y Z))
          ((num? (car (cdr (car A))))
            (cons (caar A)
              (cons @
                (cddr A))))

          # pass +Vec3
          ((isa '(+Vec3) (car A))
            (copy (ptr> @)))

          # -> (-Inf . -Inf)
          (T (cons)))))))

(dm T (X Y Z)
  (=: vec (cons X (cons Y Z)))) # improper list

(dm pr> ()
  (prinl
    (text "((X Y Z) @1 @2 @3)"
      (format (car (: vec)) *Scl)
      (format (cadr (: vec)) *Scl)
      (format (cddr (: vec)) *Scl))))

(dm fmt> () # str>
  (text "@1 @2 @3"
    (format (car (: vec)) *Scl)
    (format (cdr (: vec)) *Scl)
    (format (cddr (: vec)) *Scl)))

(dm x> @ (if (next) (set (: vec)       @) (car (: vec))))
(dm y> @ (if (next) (set (cdr (: vec)) @) (cadr (: vec))))
(dm z> @ (if (next) (con (cdr (: vec)) @) (cddr (: vec))))

# set internal structure
# ptr (formerly *-vec)
(dm ptr> @
  (if (next) (=: vec @) (: vec)))

(dm => (V) (= (ptr> V) (ptr> This)))
(dm ==> (V) (== (ptr> V) (ptr> This)))

# set x y z
# get list (useful for destructuring binds)
(dm xy> @
  (if (next)
      (prog
        (x> This @)
        (y> This (next)))
      (list
        (x> This)
        (y> This))))
(dm xyz> @
  (if (next)
      (prog
        (x> This @)
        (y> This (next))
        (z> This (next)))
      (list
        (x> This)
        (y> This)
        (z> This))))

# set list
# get list
(dm list> @
  (if (next)
      (prog
        (x> This (car @))
        (y> This (cadr @))
        (z> This (caddr @)))
      (list
        (x> This)
        (y> This)
        (z> This))))

# set/get obj
(dm vec> @
  (if (next)
      (prog
        (x> This (x> @))
        (y> This (y> @))
        (z> This (z> @)))
      (new '(+Vec3)
        (x> This)
        (y> This)
        (z> This))))

# delta

(dm dec-x> (N) (x> This (dec (x> This) N)))
(dm dec-y> (N) (y> This (dec (y> This) N)))
(dm dec-z> (N) (z> This (dec (z> This) N)))

(local) dec>
(dm dec> (N)
  (x> This (dec (x> This) N))
  (y> This (dec (y> This) N))
  (z> This (dec (z> This) N)))

(dm inc-x> (N) (x> This (inc (x> This) N)))
(dm inc-y> (N) (y> This (inc (y> This) N)))
(dm inc-z> (N) (z> This (inc (z> This) N)))

(local) inc>
(dm inc> (N)
  (x> This (inc (x> This) N))
  (y> This (inc (y> This) N))
  (z> This (inc (z> This) N)))

# arithmetic

# +

(dm +> (B)
  (new '(+Vec3)
    (+ (x> This) (x> B))
    (+ (y> This) (y> B))
    (+ (z> This) (z> B))))

(dm +xyz> (X Y Z)
  (new '(+Vec3)
    (+ (x> This) X)
    (+ (y> This) Y)
    (+ (z> This) Z)))

(dm +n> (N)
  (new '(+Vec3)
    (+ (x> This) N)
    (+ (y> This) N)
    (+ (z> This) N)))

# -

(dm -> (B)
  (new '(+Vec3)
    (- (x> This) (x> B))
    (- (y> This) (y> B))
    (- (z> This) (z> B))))

(dm -xyz> (X Y Z)
  (new '(+Vec3)
    (- (x> This) X)
    (- (y> This) Y)
    (- (z> This) Z)))

(dm -n> (N)
  (new '(+Vec3)
    (- (x> This) N)
    (- (y> This) N)
    (- (z> This) N)))

# scaling (->scalar product)
#
# see cross product for vector multiplication

(dm *xyz> (X Y Z)
  (new '(+Vec3)
    (f* (x> This) X)
    (f* (y> This) Y)
    (f* (z> This) Z)))

(dm *n> (N)
  (new '(+Vec3)
    (f* (x> This) N)
    (f* (y> This) N)
    (f* (z> This) N)))

# technically, division not possible in vector space
# really just scaling
(dm /> (N)
  (new '(+Vec3)
    (f/ (x> This) N)
    (f/ (y> This) N)
    (f/ (z> This) N)))

# dot product -> num (aka scalar)
(dm dot> (B)
  (+
    (f* (x> This) (x> B))
    (f* (y> This) (y> B))
    (f* (z> This) (z> B))))

# -> 3D vec, same as 2D output
(dm cross> (B)
  (let ((A1 A2 . A3) (ptr> This)
        (B1 B2 . B3) (ptr> B))
    (new '(+Vec3)
      (- (* A2 B3) (* A3 B2))
      (- (* A3 B1) (* A1 B3))
      (- (* A1 B2) (* A2 B1)))))

(dm mag> () # or len
  (sqrt
    (+
      (pow (x> This) 2.0)
      (pow (y> This) 2.0)
      (pow (z> This) 2.0))
    1.0))

(dm dist> (B)
  (sqrt
    (+
      (pow (- (x> This) (x> B)) 2.0)
      (pow (- (y> This) (y> B)) 2.0)
      (pow (- (z> This) (z> B)) 2.0))
    1.0))

(dm norm> ()
  (let L (mag> This)
    (new '(+Vec3)
      (f/ (x> This) L)
      (f/ (y> This) L)
      (f/ (z> This) L))))


# Vector 4
(class +Vec4)
(dm T (X Y Z W)
  (=: vec (cons X (cons Y (cons Z W))))) # improper list
