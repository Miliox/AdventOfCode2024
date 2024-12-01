package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:sort"
import "core:strconv"
import "core:simd"
import "core:container/rbtree"

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

    lookup : rbtree.Tree(i64, [2]i64) = {}
    rbtree.init_ordered(&lookup)
    defer rbtree.destroy(&lookup)

    for {
        line, err := bufio.reader_read_string(&r, '\n', context.allocator)
        if err != nil {
            break
        }
        defer delete(line, context.allocator)

        pos : int = 0
        lhs, ok1 := strconv.parse_int(line, 10, &pos)

        pos = pos + 3
        rhs, ok2 := strconv.parse_int(line[pos:], 10, &pos)

        node1 := rbtree.find(&lookup, cast(i64)lhs)
        if node1 != nil {
            node1.value[0] += 1
        } else {
            node1, _, _ = rbtree.find_or_insert(&lookup, cast(i64)lhs, [2]i64{1, 0})
        }

        node2 := rbtree.find(&lookup, cast(i64)rhs)
        if node2 != nil {
            node2.value[1] += 1
        } else {
            node2, _, _ = rbtree.find_or_insert(&lookup, cast(i64)rhs, [2]i64{0,1})
        }
    }

    acc: i64 = 0
    
    it := rbtree.iterator(&lookup, rbtree.Direction.Forward)
    node := rbtree.iterator_get(&it)
    ok : bool = true
    for {
        node, ok = rbtree.iterator_next(&it)
        if !ok {
            break
        }
        acc += node.key * node.value[0] * node.value[1]
    }
    fmt.println(acc)

}
