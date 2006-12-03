use ExtUtils::MakeMaker;
WriteMakefile(
  NAME      => q{Geo::Spline},
  VERSION_FROM => q{lib/Geo/Spline.pm},
  PREREQ_PM => {
                 strict         => 0,
                 vars           => 0,
                 constant       => 0,
                 Geo::Constants => 0.02,
                 Geo::Functions => 0.02
               },
               ($] >= 5.005 ? 
                 (
                   ABSTRACT_FROM => 'lib/Geo/Spline.pm',
                 ) : ()
               ),
             );
