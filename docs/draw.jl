# NOTE: Luxor is using JuliaGraphics/Luxor.jl/pull/48
using Luxor, BitBasis

"""
   btable(n, center=O; len=ndigits(n), width=20, title=false)

Draw a table of binary digits with `n` which can be [`BitStr`](@ref) or an `Integer`.
"""
function btable(n::Integer, center=O; len=ndigits(n; base=2), width=20, title=false)
   sethue("black")
   if title
      t = Table(2, len, width, width, center)
   else
      t = Table(1, len, width, width, center)
   end

   bstr = string(n, base=2, pad=len)
   fontsize(width ÷ 2)

   # start plotting
   col = 1
   if title
      for k in 1:size(t, 2)
         text(string(len-k+1), t[1, k], halign=:center, valign=:middle)
      end
      col += 1
   end

   for j in 1:size(t, 2)
      box(t[col, j], width, width, :stroke)
      text(string(bstr[j]), t[col, j], halign=:center, valign=:middle)
   end

   return t
end

function btable(f::Function, n::Integer, center=O;
   len=ndigits(n; base=2), width=20, title=false)
   gsave()
   # before
   before = btable(n, O - (0, 50); width=50, title=true)
   sethue("blue")
   arrow(Point(0, 10), Point(0, 50); linewidth=2)
   # after
   after = btable(f(n), O+(0, 80); width=50, title=false)
   grestore()
   return (before, after)
end

function btable(f::Function, n::BitStr, center=O; width=50, title=false)
   gsave()
   # before
   before = btable(n, O - (0, 50); width=50, title=true)
   sethue("blue")
   arrow(Point(0, 10), Point(0, 50); linewidth=2)
   # after
   after = btable(f(n), O+(0, 80); width=50, title=false)
   grestore()
   return (before, after)
end

btable(n::BitStr, center=O; width=50, title=false) =
   btable(n.val, center; len=length(n), width=width, title=title)

# TODO: push this to upstream: Luxor
function swaparrow(left::Point, right::Point, action=:fill;
    linewidth=1.0, headlength=10, headangle=pi/8, target_angle=pi/3,
    fraction=1/5, debug=false)
    gsave()
    v = right - left
    delta = fraction * v.x
    C1 = Point(left.x + delta, left.y - delta * tan(target_angle))
    C2 = Point(right.x - delta, right.y - delta * tan(target_angle))
    arrow(left, C1, C2, right, action;
        linewidth=linewidth, rightarrow=true, leftarrow=true)
    if debug
        line(left, C1, :stroke)
        line(right, C2, :stroke)
    end
    grestore()
end

@png begin
   t, _ = btable(breflect, bit"1011"; width=50, title=true)
   lineheight = 20
   sethue("red")
   swaparrow(t[1, 1] - (0, lineheight), t[1, 4] - (0, lineheight), :stroke; linewidth=2, fraction=0.25, target_angle=deg2rad(60))
   swaparrow(t[1, 2] - (0, lineheight), t[1, 3] - (0, lineheight), :stroke; linewidth=2, target_angle=deg2rad(80))
end 400 400 "docs/src/assets/breflect"
