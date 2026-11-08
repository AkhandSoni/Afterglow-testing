import Foundation

/// Radix-2 FFT used where Accelerate is unavailable. Same unnormalised forward convention.
public enum PortableFFT {
    public static func forward(_ samples: [Float]) -> ([Float], [Float]) {
        let n = samples.count
        guard n > 0, n & (n - 1) == 0 else { return ([], []) }
        var real = samples, imaginary = Array(repeating: Float(0), count: n)
        var j = 0
        for i in 0..<n {
            if i < j { real.swapAt(i, j) }
            var bit = n >> 1
            while bit > 0 && j & bit != 0 { j ^= bit; bit >>= 1 }
            j ^= bit
        }
        var length = 2
        while length <= n {
            let angle = -2 * Double.pi / Double(length)
            for start in stride(from: 0, to: n, by: length) {
                for k in 0..<(length / 2) {
                    let a = start + k, b = a + length / 2
                    let c = Float(cos(angle * Double(k))), s = Float(sin(angle * Double(k)))
                    let r = real[b] * c - imaginary[b] * s
                    let im = real[b] * s + imaginary[b] * c
                    real[b] = real[a] - r; imaginary[b] = imaginary[a] - im
                    real[a] += r; imaginary[a] += im
                }
            }
            length <<= 1
        }
        return (real, imaginary)
    }
}
