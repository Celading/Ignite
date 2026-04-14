package ignite

@Test
public class InprocTestPortInternalTestSuite {
    @TestCase
    public func testClaimInprocTestPortsAvoidsOverlappingReservations(): Unit {
        let first = claimInprocTestPorts("GET", "/same-path")
        try {
            let second = claimInprocTestPorts("GET", "/same-path")
            try {
                @Assert(first.size, Int64(8))
                @Assert(second.size, Int64(8))
                @Assert(hasUniqueInprocPorts(first), true)
                @Assert(hasUniqueInprocPorts(second), true)
                @Assert(hasInprocPortOverlap(first, second), false)
            } finally {
                releaseInprocTestPorts(second)
            }
        } finally {
            releaseInprocTestPorts(first)
        }
    }

    @TestCase
    public func testClaimInprocTestPortsStayInsideExpectedRange(): Unit {
        let ports = claimInprocTestPorts("POST", "/range-check")
        try {
            @Assert(ports.size, Int64(8))
            for (port in ports) {
                @Assert(port >= UInt16(42000), true)
                @Assert(port < UInt16(52000), true)
            }
        } finally {
            releaseInprocTestPorts(ports)
        }
    }
}

func hasInprocPortOverlap(left: Array<UInt16>, right: Array<UInt16>): Bool {
    for (port in left) {
        if (containsInprocPortArray(right, port)) {
            return true
        }
    }
    false
}

func hasUniqueInprocPorts(ports: Array<UInt16>): Bool {
    var i: Int64 = 0
    while (i < ports.size) {
        var j: Int64 = i + 1
        while (j < ports.size) {
            if (ports[i] == ports[j]) {
                return false
            }
            j += 1
        }
        i += 1
    }
    true
}

func containsInprocPortArray(ports: Array<UInt16>, target: UInt16): Bool {
    for (port in ports) {
        if (port == target) {
            return true
        }
    }
    false
}
