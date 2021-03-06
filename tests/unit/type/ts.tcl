start_server {tags {"ts"}} {
    proc create_ts {key items} {
        r del $key
        foreach {score entry} $items {
            r tsadd $key $score $entry
        }
    }
    test {TS basic TSADD and value update} {
        r tsadd ttmp 1 x
        r tsadd ttmp 3 z
        r tsadd ttmp 2 y
        set aux1 [r tsrange ttmp 0 -1 withtimes]
        r tsadd ttmp 1 xy
        set aux2 [r tsrange ttmp 0 -1 withtimes]
        list $aux1 $aux2
    } {{1 x 2 y 3 z} {1 xy 2 y 3 z}}

    test {TSLEN basics} {
        r tslen ttmp
    } {3}

    test {TSLEN non existing key} {
        r tslen ttmp-blabla
    } {0}
	
    test "TSGET on existing times" {
    	assert_equal {xy} [r tsget ttmp 1]
    	assert_equal {y} [r tsget ttmp 2]
    	assert_equal {z} [r tsget ttmp 3]
    }
	
    test "TSGET on missing times" {
    	assert_equal {} [r tsget ttmp 1.1]
    	assert_equal {} [r tsget ttmp 2.4]
    	assert_equal {} [r tsget ttmp 0]
    }
	
    test "TSRANK" {
    	create_ts ttmp {200 x 10 y 60 z 9 foo 300 bla 1 me}
    	assert_equal 6 [r tslen ttmp]
    	assert_equal 1 [r tsrank ttmp 9]
    	assert_equal 2 [r tsrank ttmp 10]
    	assert_equal 0 [r tsrank ttmp 1]
    	assert_equal 5 [r tsrank ttmp 300]
    	assert_equal "" [r tsrank ttmp 2]
    	assert_equal "" [r tsrank ttmp -200]
    	assert_equal "" [r tsrank ttmp 1200]
        assert_equal "" [r tsrank ttmpttmp 2]
    }
    
    test "TSRANGE basics" {
        
        r del ttmp
        r tsadd ttmp 1 a
        r tsadd ttmp 2 b
        r tsadd ttmp 3 a
        r tsadd ttmp 4 c

        assert_equal {a b a c} [r tsrange ttmp 0 -1]
        assert_equal {a b a} [r tsrange ttmp 0 -2]
        assert_equal {b a c} [r tsrange ttmp 1 -1]
        assert_equal {b a} [r tsrange ttmp 1 -2]
        assert_equal {a c} [r tsrange ttmp -2 -1]
        assert_equal {a} [r tsrange ttmp -2 -2]

        # out of range start index
        assert_equal {a b a} [r tsrange ttmp -5 2]
        assert_equal {a b} [r tsrange ttmp -5 1]
        assert_equal {} [r tsrange ttmp 5 -1]
        assert_equal {} [r tsrange ttmp 5 -2]

        # out of range end index
        assert_equal {a b a c} [r tsrange ttmp 0 5]
        assert_equal {b a c} [r tsrange ttmp 1 5]
        assert_equal {} [r tsrange ttmp 0 -5]
        assert_equal {} [r tsrange ttmp 1 -5]

        # withtimes
        assert_equal {1 a 2 b 3 a 4 c} [r tsrange ttmp 0 -1 withtimes]
    }
    
    test "TSRANGE novalues" {
        create_ts ttmp {200 x 10 y 60 z 9 foo 300 bla 1 me}
        assert_equal {1 9 10 60 200 300} [r tsrange ttmp 0 -1 novalues]
        assert_equal {9 10 60 200} [r tsrange ttmp 1 -2 novalues]
        assert_equal {9 10 60 200} [r tsrange ttmp 1 -2 novalues withtimes]
    }
	
    test "TSRANGEBYTIME basics" {
        r del ttmp
        r tsadd ttmp 45 achtung
        r tsadd ttmp 58 goodbye
        r tsadd ttmp 104 kaput
        r tsadd ttmp 23 ciao
        r tsadd ttmp 80 ciao

        assert_equal {} [r tsrangebytime ttmp 1 15]
        assert_equal {ciao achtung} [r tsrangebytime ttmp 20 50]
        assert_equal {ciao achtung goodbye ciao} [r tsrangebytime ttmp 20 80]

        # out of range start index
        assert_equal {} [r tsrangebytime ttmp 0 1]

        # with times
        assert_equal {23 ciao 45 achtung 58 goodbye} [r tsrangebytime ttmp 20 60 withtimes]
    }
    
    test "TSRANGEBYTIME novalues" {
        create_ts ttmp {200 x 10 y 60 z 9 foo 300 bla 1 me}
        assert_equal {1 9 10 60 200 300} [r tsrangebytime ttmp 0 1000 novalues]
        assert_equal {9 10 60 200} [r tsrangebytime ttmp 8 200 novalues]
    }
}
