package DKBench::MooseTree;

use Moose;

has 'price' => (is => 'rw', default => 10);
has 'tax'   => (is => 'rw', default => 10, lazy => 1);

has 'node' => (is => 'rw', isa => 'Any');
 
has 'parent' => (
    is        => 'rw',
    isa       => 'DKBench::MooseTree',
    predicate => 'has_parent',
    weak_ref  => 1,
);
 
has 'left' => (
    is        => 'rw',
    isa       => 'DKBench::MooseTree',
    predicate => 'has_left',
    lazy      => 1,
    builder   => '_build_child_tree',
);
 
has 'right' => (
    is        => 'rw',
    isa       => 'DKBench::MooseTree',
    predicate => 'has_right',
    lazy      => 1,
    builder   => '_build_child_tree',
);
 
before 'right', 'left' => sub {
    my ($self, $tree) = @_;
    $tree->parent($self) if defined $tree;
};
 
sub _build_child_tree {
    my $self = shift;
 
    return DKBench::MooseTree->new( parent => $self );
}

sub cost {
    my $self = shift;
    $self->price + $self->tax;
}

1;