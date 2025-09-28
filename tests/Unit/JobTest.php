<?php

use App\Models\Employer;
use App\Models\Job;

//You can also change the name of the test function here. Try and play around then see how it works. Just remember, the function is test()
it('belongs to an employer', function () {
    $employer = Employer::factory()->create();
    $job = Job::factory()->create([
        'employer_id' => $employer->id,
    ]);

    // Act and Assert
     expect($job->employer->is($employer))->toBeTrue();

    // expect(true)->toBeFalse(); //Try to change the toBe method to something else and see what results happen if you use php artisan test

    //Well, how about that. Today, I learned what this is about. The test code teaches you how to do
    //test approach development.
});

it('can have tags', function() {
    //AAA (Arrange, Act, Assert)

    $job = Job::factory()->create();

    $job->tag('Frontend');

    expect($job->tags)->toHaveCount(1);
});
