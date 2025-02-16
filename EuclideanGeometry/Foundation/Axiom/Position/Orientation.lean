import EuclideanGeometry.Foundation.Axiom.Position.Angle
import EuclideanGeometry.Foundation.Axiom.Linear.Colinear
import EuclideanGeometry.Foundation.Axiom.Linear.Parallel
import EuclideanGeometry.Foundation.Axiom.Position.Angle_trash

/- This file discuss the relative positions of points and rays on a plane. -/
noncomputable section
namespace EuclidGeom

open Classical

variable {P : Type _} [EuclideanPlane P]

/- Definition of the wedge of three points.-/

section wedge

def wedge (A B C : P) : ℝ := det (VEC A B) (VEC A C)

def oarea (A B C : P) : ℝ := wedge A B C / 2

theorem wedge213 (A B C : P) : wedge B A C = - wedge A B C := by
  dsimp only [wedge]
  have h1 : VEC B A = (-1 : ℝ) • VEC A B := by
    dsimp only [Vec.mk_pt_pt]
    rw[Complex.real_smul]
    field_simp
  rw [h1, det_smul_left_eq_mul_det, det_eq_neg_det, det_eq_neg_det (VEC A B) _]
  field_simp
  have h2 : VEC B C = VEC A C - VEC A B := by
    dsimp only [Vec.mk_pt_pt]
    exact Eq.symm (vsub_sub_vsub_cancel_right C B A)
  rw [h2, det_sub_eq_det]

theorem wedge132 (A B C : P) : wedge A C B = - wedge A B C := by
  dsimp only [wedge]
  apply det_symm

theorem wedge312 (A B C : P) : wedge C A B = wedge A B C := by
  rw [wedge213, wedge132]
  ring

theorem wedge231 (A B C : P) : wedge B C A = wedge A B C := by rw [wedge312, wedge312]

theorem wedge321 (A B C : P) : wedge C B A = - wedge A B C := by rw [wedge213, wedge231]

theorem wedge_eq_sine_mul_length_mul_length (A B C : P) (aneb : B ≠ A) (anec : C ≠ A) : wedge A B C = (Real.sin (Angle.mk_pt_pt_pt B A C aneb anec).value * (SEG A B).length *(SEG A C).length) := by
  dsimp only [wedge]
  have vecabnd : VEC A B ≠ 0 := by
   exact (ne_iff_vec_ne_zero A B).mp aneb
  have vecacnd : VEC A C ≠ 0 := by
   exact (ne_iff_vec_ne_zero A C).mp anec
  have h0 : (Angle.mk_pt_pt_pt B A C aneb anec).value = Vec_nd.angle ⟨VEC A B , vecabnd⟩ ⟨VEC A C, vecacnd⟩ := by
   dsimp only [Angle.mk_pt_pt_pt,Vec_nd.angle,angle_value_eq_dir_angle]
   rfl
  rw [h0]
  apply det_eq_sin_mul_norm_mul_norm ⟨VEC A B , vecabnd⟩ ⟨VEC A C, vecacnd⟩

theorem colinear_iff_wedge_eq_zero (A B C : P) : (colinear A B C) ↔ (wedge A B C = 0) := by
  dsimp only [wedge]
  by_cases B ≠ A
  have vecabnd : VEC A B ≠ 0 := by
    exact (ne_iff_vec_ne_zero A B).mp h
  constructor
  intro k
  apply (det_eq_zero_iff_eq_smul (VEC A B) (VEC A C) vecabnd).mpr
  exact (colinear_iff_eq_smul_vec_of_ne h).mp k
  intro k
  apply (det_eq_zero_iff_eq_smul (VEC A B) (VEC A C) vecabnd).mp at k
  exact (colinear_iff_eq_smul_vec_of_ne h).mpr k
  simp at h
  have vecab0 : VEC A B = 0 := by
    exact (eq_iff_vec_eq_zero A B).mp h
  constructor
  intro
  dsimp only [det]
  field_simp [vecab0]
  intro
  rw [h]
  exact triv_colinear A C

theorem wedge_pos_iff_angle_pos (A B C : P) (nd : ¬colinear A B C) : (0 < wedge A B C) ↔ (0 < (Angle.mk_pt_pt_pt B A C (ne_of_not_colinear nd).2.2 (ne_of_not_colinear nd).2.1.symm).value ∧ (Angle.mk_pt_pt_pt B A C (ne_of_not_colinear nd).2.2 (ne_of_not_colinear nd).2.1.symm).value < π) := by
  have h1 : 0 < (SEG A B).length := by
      have abnd : (SEG A B).is_nd := (ne_of_not_colinear nd).2.2
      exact length_pos_iff_nd.mpr (abnd)
  have h2 : 0 < (SEG A C).length := by
      have acnd : (SEG A C).is_nd := (ne_of_not_colinear nd).2.1.symm
      exact length_pos_iff_nd.mpr (acnd)
  constructor
  · intro h0
    rw[wedge_eq_sine_mul_length_mul_length A B C (ne_of_not_colinear nd).2.2 (ne_of_not_colinear nd).2.1.symm] at h0
    have h3 : 0 < Real.sin ((Angle.mk_pt_pt_pt B A C (ne_of_not_colinear nd).2.2 (ne_of_not_colinear nd).2.1.symm).value) := by
      field_simp at h0
      exact h0
    rw [sin_pos_iff_angle_pos] at h3
    exact h3
  rw[wedge_eq_sine_mul_length_mul_length A B C (ne_of_not_colinear nd).2.2 (ne_of_not_colinear nd).2.1.symm]
  intro h0
  have h3 : 0 < Real.sin ((Angle.mk_pt_pt_pt B A C (ne_of_not_colinear nd).2.2 (ne_of_not_colinear nd).2.1.symm).value) := (sin_pos_iff_angle_pos (Angle.mk_pt_pt_pt B A C (ne_of_not_colinear nd).2.2 (ne_of_not_colinear nd).2.1.symm)).mpr h0
  field_simp
  exact h2

end wedge

/- Directed distance-/
section oriented_distance

def odist (A : P) (ray : Ray P) : ℝ := det ray.2.1 (VEC ray.1 A)


/- may insert some theorems relating colinearity and zero directed distance, which might take some efforts-/

theorem odist_eq_zero_iff_colinear (A : P) (ray : Ray P) : odist A ray = 0 ↔ (∃ t : ℝ, VEC ray.1 A = t • ray.2.1) := by
  constructor
  intro k
  dsimp only [odist] at k
  apply (det_eq_zero_iff_eq_smul (ray.2.1) (VEC ray.1 A) (Dir.tovec_ne_zero ray.2)).mp
  exact k
  intro e
  apply (det_eq_zero_iff_eq_smul (ray.2.1) (VEC ray.1 A) (Dir.tovec_ne_zero ray.2)).mpr
  exact e

theorem odist_eq_sine_mul_length (A : P) (ray : Ray P) (h : A ≠ ray.source) : odist A ray = Real.sin ((Angle.mk_ray_pt ray A h).value) * (SEG ray.source A).length := by sorry

theorem wedge_eq_odist_mul_length (A B C : P) (aneb : B ≠ A) : (wedge A B C) = ((odist C (RAY A B aneb)) * (SEG A B).length) := by
  by_cases p : C ≠ A
  rw [wedge_eq_sine_mul_length_mul_length A B C aneb p,odist_eq_sine_mul_length C (RAY A B aneb)]
  rw [mul_assoc (Real.sin ((Angle.mk_ray_pt (RAY A B aneb) C p).value)) ((SEG (RAY A B aneb).source C).length) ((SEG A B).length),mul_comm ((SEG (RAY A B aneb).source C).length) ((SEG A B).length),←mul_assoc (Real.sin ((Angle.mk_ray_pt (RAY A B aneb) C p).value)) ((SEG A B).length) ((SEG (RAY A B aneb).source C).length)]
  congr
  simp at p
  have vecac0 : VEC A C = 0 := by
    exact (eq_iff_vec_eq_zero A C).mp p
  have vecrayc0 : VEC (RAY A B aneb).source C = 0 := by
    exact vecac0
  dsimp only [wedge,odist,det]
  field_simp [vecac0,vecrayc0]

end oriented_distance

/- Positions of points on a line, ray, oriented segments. -/

section point_toray

def Ray.sign (A : P) (ray : Ray P) : ℝ := Real.sign (odist A ray)

def IsOnLeftSide (A : P) (ray : Ray P) : Prop := by
  by_cases 0 < odist A ray
  · exact True
  · exact False

def IsOnRightSide (A : P) (ray : Ray P) : Prop := by
  by_cases odist A ray < 0
  · exact True
  · exact False

def OnLine (A : P) (ray : Ray P) : Prop := by
  by_cases odist A ray = 0
  · exact True
  · exact False

def OffLine (A : P) (ray : Ray P) : Prop := by
  by_cases odist A ray = 0
  · exact False
  · exact True

theorem online_iff_online (A : P) (ray : Ray P) : OnLine A ray ↔ Line.IsOn A ray.toLine := by
  dsimp only [OnLine]
  by_cases h : odist A ray = 0
  · simp
    constructor
    intro
    sorry
    sorry
  constructor
  · intro k
    sorry
  dsimp only [Line.IsOn]
  intro h0
  sorry

/- Relation of position of points on a ray and directed distance-/

end point_toray

scoped infix : 50 "LiesOnLeft" => IsOnLeftSide
scoped infix : 50 "LiesOnRight" => IsOnRightSide

section handside

theorem same_sign_of_parallel (A B : P) (ray : Ray P) (bnea : B ≠ A) (para : parallel (RAY A B bnea)  ray) : ray.sign A = ray.sign B := by
  have h0 : odist A ray = odist B ray := by
    unfold odist
    have h1 : det ray.2.1 (VEC ray.1 B) = det ray.2.1 (VEC ray.1 A) + det ray.2.1 (VEC A B) := by
      rw [←vec_add_vec ray.1 A B]
      rw [det_add_right_eq_add_det]
    have h2 : det ray.2.1 (VEC A B) = 0 := by
      unfold parallel at para
      --unfold ProjObj.toProj at para
      have h3 : Dir.toProj ray.2 = Vec_nd.toProj (⟨(VEC A B) , (VEC_nd A B bnea).2⟩ : Vec_nd) := para.symm
      have h4 : Vec_nd.toProj ray.2.toVec_nd = Vec_nd.toProj (⟨(VEC A B) , (VEC_nd A B bnea).2⟩ : Vec_nd) := by
        rw [← h3]
        exact dir_toVec_nd_toProj_eq_dir_toProj ray.2
      exact det_eq_zero_of_toProj_eq (⟨ray.2.1 , Dir.tovec_ne_zero ray.2⟩ : Vec_nd) (⟨(VEC A B) , (VEC_nd A B bnea).2⟩ : Vec_nd) h4
    rw [h2] at h1
    rw [add_zero] at h1
    exact h1.symm
  unfold Ray.sign
  rw [h0]

theorem no_intersect_of_same_sign (A B : P) (ray : Ray P) (signeq : (ray.sign A) * (ray.sign B) = 1) : ¬∃ (C : P), (Seg.IsOn C (SEG A B)) ∧ (Line.IsOn C ray.toLine) := sorry

theorem intersect_of_diff_sign (A B : P) (ray : Ray P) (signdiff : ¬ (ray.sign A) * (ray.sign B) = 1) : ∃ (C : P), (Seg.IsOn C (SEG A B)) ∧ (Line.IsOn C ray.toLine) := sorry

end handside

/- Position of two rays -/
section ray_toray

/- Statement of his theorem should change, since ray₀.source ≠ ray₂.source. -/
theorem intersect_of_ray_on_left_iff (ray₁ ray₂ : Ray P) (h : ray₂.source ≠ ray₁.source) : let ray₀ := Ray.mk_pt_pt ray₁.source ray₂.source h; (0 < value_of_angle_of_two_ray_of_eq_source ray₀ ray₁ rfl) ∧ (value_of_angle_of_two_ray_of_eq_source ray₀ ray₁ rfl < value_of_angle_of_two_ray_of_eq_source ray₀ ray₂ sorry) ∧ (value_of_angle_of_two_ray_of_eq_source ray₀ ray₂ sorry < π) ↔ (∃ A : P, (A LiesOn ray₁) ∧ (A LiesOn ray₂) ∧ (A LiesOnLeft ray₀))  := sorry

end ray_toray



/- Position of two lines; need a function to take the intersection of two lines (when they intersect). -/


/- A lot more theorems regarding positions -/
/- e.g. 180 degree implies colinear -/

end EuclidGeom
