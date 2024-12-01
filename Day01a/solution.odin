package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:sort"
import "core:strconv"
import "core:simd"

main :: proc() {
    fd, open_err := os.open("input.txt")
    if open_err != os.ERROR_NONE {
        fmt.println(open_err)
        return;
    }
    defer os.close(fd)

    r: bufio.Reader
    buffer: [1024]byte
    bufio.reader_init_with_buf(&r, os.stream_from_handle(fd), buffer[:])
    defer bufio.reader_destroy(&r)

    lhs_seq := make([dynamic]i64, 0, 128)
    rhs_seq := make([dynamic]i64, 0, 128)

    for {
        line, err := bufio.reader_read_string(&r, '\n', context.allocator)
        if err != nil {
            break
        }
        defer delete(line, context.allocator)

        pos : int = 0
        lhs, ok1 := strconv.parse_int(line, 10, &pos)
        append(&lhs_seq, cast(i64)lhs)

        pos = pos + 3
        rhs, ok2 := strconv.parse_int(line[pos:], 10, &pos)
        append(&rhs_seq, cast(i64)rhs)
    }
    sort.merge_sort(lhs_seq[0:len(lhs_seq)])
    sort.merge_sort(rhs_seq[0:len(rhs_seq)])
    arr_len := len(lhs_seq)

    // pad to be a factor of 4
    for i := len(lhs_seq); (i & 0b11) != 0; i += 1 {
        append(&lhs_seq, cast(i64)0)
        append(&rhs_seq, cast(i64)0)
    }
    arr_len = len(lhs_seq)

    acc := simd.i64x4{0,0,0,0}
    for i := 0; i < arr_len; i += 4 {
        lhs_op := simd.from_slice(simd.i64x4, lhs_seq[i:i+4])
        rhs_op := simd.from_slice(simd.i64x4, rhs_seq[i:i+4])

        lhs_op = simd.sub(lhs_op, rhs_op)
        lhs_op = simd.abs(lhs_op)

        acc = simd.add(acc, lhs_op)
    }
    total := simd.reduce_add_ordered(acc)
    fmt.println(total)
}
