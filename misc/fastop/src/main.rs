/** 
 * from: https://www.mdpi.com/1424-8220/20/5/1515
 * 
 */

use plotlib::page::Page;
use plotlib::repr::Plot;
use plotlib::style::LineStyle;
use plotlib::view::ContinuousView;

use softposit::{P8E0};
use num_traits::ToPrimitive;

fn sigmoid(x: f64) -> f64 {
    1.0 / (1.0 + (-x).exp())
}

/// ```
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
fn fast_sigmoid(x: f64) -> f64 {
    let X= P8E0::from(x).to_bits();
    let invert_bit = 1 << (8 - 2);
    let Y = (invert_bit + (X >> 1)) >> 1;
    let Y = P8E0::from_bits(Y);
    let y = Y.to_f64().unwrap();
    y
}

fn twice(x: f64) -> f64 {
    x + x
}

fn compl1(x: f64) -> f64 {
    // !(x as u64) as f64
    todo!()
}

fn fast_tanh(x: f64) -> f64 {
    let x_n = if x > 0.0 { -x } else { x };
    let s = x > 0.0;
    let y_n = 0.5*(twice(fast_sigmoid(twice(x_n))));
    let y = if s { -y_n } else { y_n };
    y
}


fn main() {
    let (lower, upper) = (-5.0, 5.0);

    let f1 = 
        Plot::from_function(|x| sigmoid(x), lower, upper).line_style(LineStyle::new().colour("red"));

    let f2 =
        Plot::from_function(|x| fast_sigmoid(x), lower, upper).line_style(LineStyle::new().colour("blue"));

    let f3 = 
        Plot::from_function(|x| x.tanh(), lower, upper).line_style(LineStyle::new().colour("green"));

    let f4 =
        Plot::from_function(|x| fast_tanh(x), lower, upper).line_style(LineStyle::new().colour("yellow"));

    let sigmoid = ContinuousView::new().add(f1).add(f2);    
    let tanh = ContinuousView::new().add(f3).add(f4);
    
    Page::single(&sigmoid).save("sigmoid.svg").expect("saving svg");
    Page::single(&tanh).save("tanh.svg").expect("saving svg");
}
