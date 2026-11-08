fn main() {
    println!(
        "cargo:rustc-env=AFTERGLOW_TARGET={}",
        std::env::var("TARGET").unwrap()
    );
    tauri_build::build()
}
