use ExtUtils::MakeMaker;
WriteMakefile
(
          'PL_FILES' => {
                          'OeLinkBin.PL' => 'blib/arch/jacks.so'
                        },
          'INSTALLDIRS' => 'site',
          'NAME' => 'jacks',
          'EXE_FILES' => [],
          'VERSION_FROM' => 'lib/jacks.pm',
          'PREREQ_PM' => {
                           'Test::More' => 0
                         }
        )
;
