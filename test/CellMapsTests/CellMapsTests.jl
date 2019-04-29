module CellMapsTests
##
using Numa
using Test

using Numa.Quadratures
using Numa.CellQuadratures
import Numa.CellIntegration: cellcoordinates, cellbasis

using Numa.CellValues
using Numa.CellValues: IndexCellArray
import Numa.CellValues: cellsize

using Numa.Polytopes
using Numa.Polytopes: PointInt

using Numa.RefFEs
using Numa.FieldValues

import Numa: gradient
using Numa.CellValues: ConstantCellValue

using Numa.FESpaces: ConformingFESpace

using Numa.Maps
using Numa.Maps: AnalyticalField

using Numa.Geometry
using Numa.Geometry.Cartesian
using Numa.Geometry.Unstructured

using Numa.CellMaps
using Numa.CellMaps: ConstantCellMapValues


l = 10

include("CellMapsTestsMocks.jl")

##
grid = CartesianGrid(partition=(3,3),domain=(0,1,0,1))
trian = triangulation(grid)
meshcoords = cellcoordinates(trian)
quad = quadrature(trian,order=0)
points = coordinates(quad)
phi = geomap(trian)
map, state = iterate(phi)

@testset "InnerFieldValuesFieldValues" begin

  siff = varinner(sfv,sfv)
  siffa = [ inner(sfva[i],sfva[i]) for i in 1:4 ]

  @test length(siff) == l
  @test cellsize(siff) == size(sfva)
  for a in siff
    @assert a == siffa
  end

  viff = varinner(vfv,vfv)
  viffa = [ inner(vfva[i],vfva[i]) for i in 1:4 ]

  @test length(viff) == l
  @test cellsize(viff) == size(vfva)
  for a in viff
    @assert a == viffa
  end

  tiff = varinner(tfv,tfv)
  tiffa = [ inner(tfva[i],tfva[i]) for i in 1:4 ]

  @test length(tiff) == l
  @test cellsize(tiff) == size(tfva)
  for a in tiff
    @assert a == tiffa
  end

end

@testset "InnerBasisValuesFieldValues" begin

  siff = varinner(sbv,sfv)
  siffa = zeros(3,4)
  for j in 1:4
    for i in 1:3
      siffa[i,j] = inner(sbva[i,j],sfva[j])
    end
  end

  @test length(siff) == l
  @test cellsize(siff) == size(siffa)
  for a in siff
    @assert a == siffa
  end

  viff = varinner(vbv,vfv)
  viffa = zeros(3,4)
  for j in 1:4
    for i in 1:3
      viffa[i,j] = inner(vbva[i,j],vfva[j])
    end
  end

  @test length(viff) == l
  @test cellsize(viff) == size(viffa)
  for a in viff
    @assert a == viffa
  end

  tiff = varinner(tbv,tfv)
  tiffa = zeros(3,4)
  for j in 1:4
    for i in 1:3
      tiffa[i,j] = inner(tbva[i,j],tfva[j])
    end
  end

  @test length(tiff) == l
  @test cellsize(tiff) == size(tiffa)
  for a in tiff
    @assert a == tiffa
  end

end

@testset "InnerBasisValuesBasisValues" begin

  siff = varinner(sbv,sbv)
  siffa = zeros(3,3,4)
  for j in 1:4
    for i in 1:3
      for k in 1:3
        siffa[k,i,j] = inner(sbva[k,j],sbva[i,j])
      end
    end
  end

  @test length(siff) == l
  @test cellsize(siff) == size(siffa)
  for a in siff
    @assert a == siffa
  end

  viff = varinner(vbv,vbv)
  viffa = zeros(3,3,4)
  for j in 1:4
    for i in 1:3
      for k in 1:3
        viffa[k,i,j] = inner(vbva[k,j],vbva[i,j])
      end
    end
  end

  @test length(viff) == l
  @test cellsize(viff) == size(viffa)
  for a in viff
    @assert a == viffa
  end

  tiff = varinner(tbv,tbv)
  tiffa = zeros(3,3,4)
  for j in 1:4
    for i in 1:3
      for k in 1:3
        tiffa[k,i,j] = inner(tbva[k,j],tbva[i,j])
      end
    end
  end

  @test length(tiff) == l
  @test cellsize(tiff) == size(tiffa)
  for a in tiff
    @assert a == tiffa
  end

end

@testset "ExpandBasisValuesFieldValues" begin

  sexpand = expand(sbv,sfv2)
  sexpanda = Array{Float64,1}(undef,(4,))
  for j in 1:4
    sexpanda[j] = 0.0
    for i in 1:3
      sexpanda[j] += sbva[i,j]*sfva[i]
    end
  end

  @test length(sexpand) == l
  @test cellsize(sexpand) == size(sexpanda)
  for a in sexpand
    @assert a == sexpanda
  end

  vexpand = expand(sbv,vfv2)
  vexpanda = Array{VectorValue{2},1}(undef,(4,))
  for j in 1:4
    vexpanda[j] = zero(VectorValue{2})
    for i in 1:3
      vexpanda[j] += sbva[i,j]*vfva[i]
    end
  end

  @test length(vexpand) == l
  @test cellsize(vexpand) == size(vexpanda)
  for a in vexpand
    @assert a == vexpanda
  end

  vexpand = expand(vbv,sfv2)
  vexpanda = Array{VectorValue{2},1}(undef,(4,))
  for j in 1:4
    vexpanda[j] = zero(VectorValue{2})
    for i in 1:3
      vexpanda[j] += vbva[i,j]*sfva[i]
    end
  end

  @test length(vexpand) == l
  @test cellsize(vexpand) == size(vexpanda)
  for a in vexpand
    @assert a == vexpanda
  end

end

# include("PolynomialsTestsMocks.jl")

@testset "ConstantCellBasis" begin

  l = 10

  refquad = TensorProductQuadrature(orders=(5,4))
  refpoints = coordinates(refquad)
  quad = ConstantCellQuadrature(refquad,l)
  points = coordinates(quad)
  polytope = Polytope(Polytopes.PointInt{2}(1,1))
  reffe = LagrangianRefFE{2,ScalarValue}(polytope,[1,1])
  refbasis = reffe.shfbasis
  refvals = evaluate(refbasis,refpoints)
  vals = ConstantCellMapValues(refbasis,points)

  @test isa(vals,CellBasisValues{Float64})

  for refvals2 in vals
    @assert refvals2 == refvals
  end

  basis = ConstantCellMap(refbasis,l)

  @test isa(basis,CellBasis{2,Float64})

  vals = evaluate(basis,points)

  @test isa(vals,CellBasisValues{Float64})

  # @test isa(vals,ConstantCellArray{Float64,2})
  @test isa(vals,CellArray{Float64,2})
  # @santiagobadia: It is wrong, it cannot be constant, since points are just a CellArray

  for refvals2 in vals
    @assert refvals2 == refvals
  end

  vals = evaluate(basis,vfv)

  @test isa(vals,CellBasisValues{Float64})

  @test isa(vals,ConstantCellMapValues)

  refbasisgrad = gradient(refbasis)

  refvalsgrad = evaluate(refbasisgrad,refpoints)

  basisgrad = gradient(basis)

  valsgrad = evaluate(basisgrad,points)

  @test isa(valsgrad,CellBasisValues{VectorValue{2}})

  @test isa(valsgrad,CellArray{VectorValue{2},2})
  # @santiagobadia : Idem as above

  for refvalsgrad2 in valsgrad
    @assert refvalsgrad2 == refvalsgrad
  end

  valsgrad = ConstantCellMapValues(refbasisgrad,points)

  @test isa(valsgrad,CellBasisValues{VectorValue{2}})

  for refvalsgrad2 in valsgrad
    @assert refvalsgrad2 == refvalsgrad
  end

end

@testset "CellBasisOps" begin

  sb = ScalarBasisMock()

  vals = evaluate(sb + sb,vfv)

  @test isa(sb + sb,CellBasis{2,Float64})

  for a in vals
    @assert a == sbva + sbva
  end

  vals = evaluate(sb - sb,vfv)

  @test isa(sb - sb,CellBasis{2,Float64})

  for a in vals
    @assert a == sbva - sbva
  end

  vals = evaluate(sb * sb,vfv)

  @test isa(sb * sb,CellBasis{2,Float64})

  for a in vals
    @assert a == sbva .* sbva
  end

  vals = evaluate(sb / sb,vfv)

  @test isa(sb / sb,CellBasis{2,Float64})

  for a in vals
    @assert a == sbva ./ sbva
  end

  vals = evaluate(inner(sb,sb),vfv)

  @test isa(vals,CellArray{Float64,3})

  sf = ScalarFieldMock()

  vals = evaluate(inner(sf,sf),vfv)

  @test isa(vals,CellArray{Float64,1})

  vals = evaluate(inner(sb,sf),vfv)

  @test isa(vals,CellArray{Float64,2})

end

@testset "CellFieldFromCompose" begin

  @eval begin

    ufun(x::Point{2}) = x[1]*x[2] + x[1]

    gradufun(x::Point{2}) = VectorValue(x[2]+1.0,x[1])

    gradient(::typeof(ufun)) = gradufun

  end

  @test isa(phi,CellField)
  @test isa(ufun,Function)

  ufun
  cfield = compose(ufun,phi)

  @test isa(cfield,CellField{2,Float64})

  cfieldgrad = gradient(cfield)

  @test isa(cfieldgrad,CellField{2,VectorValue{2}})

  uatx = evaluate(cfield,points)

  ugradatx = evaluate(cfieldgrad,points)

  x = evaluate(phi,points)

  for (ui,uigrad,xi) in zip(uatx,ugradatx,x)
    @assert ui == ufun.(xi)
    @assert uigrad == gradufun.(xi)
  end

end

@testset "CellFieldFromComposeExtended" begin

  @eval begin

    fun(x::Point{2},u::VectorValue{2}) = x[1]*x[2]*u[2] + x[1]*u[1]

    gradfun(x::Point{2},u::VectorValue{2}) = VectorValue(x[2]*u[2]+u[1],x[1]*u[2])

    gradient(::typeof(fun)) = gradfun

  end

  @test isa(phi,CellField)
  @test isa(fun,Function)

  u = phi
  @test isa(u,CellField)

  cfield = compose(fun,phi,u)

  @test isa(cfield,CellField{2,Float64})

  cfieldgrad = gradient(cfield)

  @test isa(cfieldgrad,CellField{2,VectorValue{2}})

  cfatx = evaluate(cfield,points)

  gradcfatx = evaluate(cfieldgrad,points)

  x = evaluate(phi,points)

  uatx = evaluate(u,x)

  for (cfi,cfigrad,xi,ui) in zip(cfatx,gradcfatx,x,uatx)
    @assert cfi == fun.(xi,ui)
    @assert cfigrad == gradfun.(xi,ui)
  end

end

@testset "CellBasisWithGeomap" begin

  basis = cellbasis(trian)

  physbasis = attachgeomap(basis,phi)

  vals = evaluate(physbasis,points)

  @test isa(vals,CellArray{Float64,2})

  physbasisgrad = gradient(physbasis)

  valsgrad = evaluate(physbasisgrad,points)

  tv1 = VectorValue(-1.5, -1.5)
  tv2 = VectorValue(1.5, -1.5)
  tv3 = VectorValue(-1.5, 1.5)
  tv4 = VectorValue(1.5, 1.5)

  valsgradref = reshape([tv1, tv2, tv3, tv4],(4,1))

  for v in valsgrad
    @assert v ≈ valsgradref
  end

end

end  # module CellFieldsTests
