/**
 * from: https://www.mdpi.com/1424-8220/20/5/1515
 *
 *
 * note: '!' behaves like C's '~' when applied to unsigneds, i.e. u8, u16, u32, u64, u128.
 */
use plotlib::page::Page;
use plotlib::repr::Plot;
use plotlib::style::LineStyle;
use plotlib::view::ContinuousView;

#[allow(non_snake_case)]
mod fast_af {

    use num_traits::ToPrimitive;
    use softposit::P8E0;

    const N: u8 = 8;

    pub fn sigmoid(x: f64) -> f64 {
        1.0 / (1.0 + (-x).exp())
    }

    pub fn elu(x: f64) -> f64 {
        let alpha = 1.0;
        match x.is_sign_positive() {
            true => x,
            _ => alpha * (x.exp() - 1.0),
        }
    }

    /// e.g.:
    /// ```text
    /// x           = 4.6_f64
    /// X           = 01110001
    ///                  -> there is no 4.6 in P<8,0>,
    ///                     it's rounded to 4.5
    /// invert_bit  = 01000000 +
    /// X >> 1      = 00111000 =
    ///               ----------
    ///               01111000
    /// Y           = 00111100
    /// y           = 0.9375
    /// ```
    pub fn fast_sigmoid(x: f64) -> f64 {
        let x_n = if x > 0_f64 { x } else { -x };
        let X = P8E0::from(x_n).to_bits();
        let s = x > 0_f64;
        let invert_bit = 1 << (N - 2);
        let Y = (invert_bit + (X >> 1)) >> 1;
        let Y = match s {
            true => Y,
            _ => _c1(Y),
        };
        P8E0::from_bits(Y).to_f64().unwrap()
    }

    fn _c1(X: u8) -> u8 {
        let invert_bit: u8 = 1 << (N - 2);
        invert_bit.saturating_sub(X) // (invert_bit - X) with boundary check
                                     // same as `invert_bit.checked_sub(&X).unwrap_or(0)` but
                                     // this returned a warning: warning: manual saturating arithmetic
                                     //   |
                                     //   |         invert_bit.checked_sub(&X).unwrap_or(0) // (invert_bit - X) with boundary check
                                     //   |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ help: try using `saturating_sub`: `invert_bit.saturating_sub(&X)`
                                     //   = note: `#[warn(clippy::manual_saturating_arithmetic)]` on by default
    }

    pub fn c1(X: P8E0) -> P8E0 {
        let X = X.to_bits();
        let Y = _c1(X);
        P8E0::from_bits(Y)
    }

    pub fn fast_elu(x: f64) -> f64 {
        let neg = |x: f64| -x;
        let reciprocate = |x: f64| x.recip();
        let half = |x: f64| x / 2.0;
        let twice = |x: f64| x + x;

        let y_n = neg(twice(comp_one(half(reciprocate(fast_sigmoid(neg(x)))))));

        match x.is_sign_positive() {
            true => x,
            _ => y_n,
        }
    }

    fn _inv(X: u8) -> (u8, u8) {
        let msb = 1 << (N - 1);
        let Y = {
            let sign_mask = !((msb | (msb - 1)) >> 1);
            X ^ !sign_mask
        };

        let Y2 = X ^ !msb; // !(1 << (N - 1)) == 0x7f if N = 8 bits

        if Y != Y2 {
            dbg!(Y, Y2);
        }

        (Y, Y2 + 1)
    }

    /// page 7
    pub fn inv(x: f64) -> (f64, f64) {
        let X = P8E0::from(x).to_bits();
        let (Y, Y2) = _inv(X);
        let y = P8E0::from_bits(Y).to_f64().unwrap();
        let y2 = P8E0::from_bits(Y2).to_f64().unwrap();
        (y, y2)
    }

    pub fn comp_one(x: f64) -> f64 {
        let X = P8E0::from(x);
        let Y = c1(X);
        Y.to_f64().unwrap()
    }

    pub fn fast_tanh(x: f64) -> f64 {
        let twice = |x: f64| x + x;
        let x_n = if x > 0.0 { -x } else { x };
        let s = x >= 0.0;
        let y_n = -comp_one(twice(fast_sigmoid(twice(x_n))));
        if s {
            -y_n
        } else {
            y_n
        }
    }
}

fn main() {
    let (lower, upper) = (-5.0, 5.0);

    let f1 = Plot::from_function(fast_af::sigmoid, lower, upper)
        .line_style(LineStyle::new().colour("red"));

    let f2 = Plot::from_function(fast_af::fast_sigmoid, lower, upper)
        .line_style(LineStyle::new().colour("blue"));

    let f3 =
        Plot::from_function(|x| x.tanh(), lower, upper).line_style(LineStyle::new().colour("red"));

    let f4 = Plot::from_function(fast_af::fast_tanh, lower, upper)
        .line_style(LineStyle::new().colour("blue"));

    let f5 = Plot::from_function(|x| 1.0 / x, 0.05, 1.0).line_style(LineStyle::new().colour("red"));

    let f6_a = Plot::from_function(|x| fast_af::inv(x).0, 0.05, 1.0)
        .line_style(LineStyle::new().colour("blue"));

    let f6_b = Plot::from_function(|x| fast_af::inv(x).1, 0.05, 1.0)
        .line_style(LineStyle::new().colour("green"));

    let f7 =
        Plot::from_function(|x| (1.0 - x), 0.0, 1.0).line_style(LineStyle::new().colour("red"));

    let f8 = Plot::from_function(fast_af::comp_one, 0.0, 1.0)
        .line_style(LineStyle::new().colour("blue"));

    let f9 =
        Plot::from_function(fast_af::elu, lower, 2.0).line_style(LineStyle::new().colour("red"));

    let f10 = Plot::from_function(fast_af::fast_elu, lower, 2.0)
        .line_style(LineStyle::new().colour("blue"));

    let sigmoid = ContinuousView::new().add(f1).add(f2);
    let tanh = ContinuousView::new().add(f3).add(f4);
    let inv = ContinuousView::new().add(f5).add(f6_a).add(f6_b);
    let c1 = ContinuousView::new().add(f7).add(f8);
    let elu = ContinuousView::new().add(f9).add(f10);

    Page::single(&sigmoid)
        .save("sigmoid.svg")
        .expect("saving svg");
    Page::single(&tanh).save("tanh.svg").expect("saving svg");
    Page::single(&inv).save("inv.svg").expect("saving svg");
    Page::single(&c1).save("comp1.svg").expect("saving svg");
    Page::single(&elu).save("elu.svg").expect("saving svg");
}

#[test]
fn my_test() {
    // assert_eq!(_c1(0b0001_1001), 0b0010_0111);
}

// use plotters::prelude::*;

// const OUT_FILE_NAME: &'static str = "sample.svg";
// fn main() -> Result<(), Box<dyn std::error::Error>> {
//     let root = SVGBackend::new(OUT_FILE_NAME, (1024, 768)).into_drawing_area();
//     root.fill(&WHITE)?;

//     let mut chart = ChartBuilder::on(&root)
//         .x_label_area_size(35)
//         .y_label_area_size(40)
//         .right_y_label_area_size(40)
//         .margin(5)
//         .caption("Dual Y-Axis Example", ("sans-serif", 50.0).into_font())
//         .build_cartesian_2d(0f32..10f32, (0.1f32..1e10f32).log_scale())?
//         .set_secondary_coord(0f32..10f32, -1.0f32..1.0f32);

//     chart
//         .configure_mesh()
//         .disable_x_mesh()
//         .disable_y_mesh()
//         .y_desc("Log Scale")
//         .y_label_formatter(&|x| format!("{:e}", x))
//         .draw()?;

//     chart
//         .configure_secondary_axes()
//         .y_desc("Linear Scale")
//         .draw()?;

//     chart
//         .draw_series(LineSeries::new(
//             (0..=100).map(|x| (x as f32 / 10.0, (1.02f32).powf(x as f32 * x as f32 / 10.0))),
//             &BLUE,
//         ))?
//         .label("y = 1.02^x^2")
//         .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], &BLUE));

//     chart
//         .draw_secondary_series(LineSeries::new(
//             (0..=100).map(|x| (x as f32 / 10.0, (x as f32 / 5.0).sin())),
//             &RED,
//         ))?
//         .label("y = sin(2x)")
//         .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], &RED));

//     chart
//         .configure_series_labels()
//         .background_style(&RGBColor(128, 128, 128))
//         .draw()?;

//     // To avoid the IO failure being ignored silently, we manually call the present function
//     root.present().expect("Unable to write result to file, please make sure 'plotters-doc-data' dir exists under current dir");
//     println!("Result has been saved to {}", OUT_FILE_NAME);

//     Ok(())
// }
