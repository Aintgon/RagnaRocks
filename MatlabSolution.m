function germanTank()
%     #######################################
%     # Finally, let's call the script
%     #######################################
%     if __name__ == '__main__':
%         # Notice that we also might use other values for the parameters `N_min,
%         # N_max, b_min, b_max`.  up to `N_max = 100_000_000` and
%         # `b_max = 100_000_000`. We just set the limit at 100_000 for now to make
%         # the code run fast.
clc;
T = 100 ;
N_min = 100 ; N_max = 100000;
b_min = 100; b_max = 100000;
[n,b_predict,score]= run_problem_instances(@another_silly_that_goes_through_all_data, T,...
    N_min, N_max, b_min, b_max);
% [n,b_predict,score]= run_problem_instances(@my_silly_f, T,...
%     N_min, N_max, b_min, b_max);

fprintf('\n[n= %d b_predict=%d score=%f]\n',n,b_predict,score)
%         #    run_problem_instances(my_silly_f, T,
%         #                           N_min, N_max, b_min, b_max)
end

function seq = random_sequence(b, N)
% seq = zeros(N,1);
% for iloop=1:N
%     seq(iloop) = randi(b,1); %  b inclusive
% end
% seq = randi([1,b],N-1,1);
seq = unidrnd(b,N,1);
end


function  l = hit(b_predict, b_true, deviation)
%     '''
%     Arguments:
%         b_predict: int, the predicted value of the upper bound b.
%         b_true: int, the true value of the upper bound b.
%         deviation: int, the allowed deviation
%     '''
is_hit = (b_predict>=b_true - deviation ) &  (b_predict<= b_true + deviation) ;
if is_hit
    l = 1;
else
    l = 0;
end
end


function [n,b_predict,score] = run_problem_instances(f, T, N_min, N_max, b_min, b_max)
%     '''
%     f: Our function that takes in `sequence, N, m`
%         sequence: a generator function that yields (n, value) until `N`
%         N: The total amount of values we see if we never predict early.
%         m: The allowed deviation
%     T: int, the number of trials.
%     N_min, N_max: lower and upper bounds for `N`
%     b_min, bmax: lower and upper bounds for `b`.
%     '''
% fprintf(f,'Running {T} trials.')
tot_penalty = 0 ;
for t = 1:T
    %     N = randi([N_min,N_max],1);
    N = unidrnd(N_max,1);
    %     b_true = randi([b_min,b_max],1);
    b_true = unidrnd(b_max,1);
    
    %  # we let `m` (the deviation) be anywhere between 1% and 25% of `N`. :)
    rn = ((0.25-0.01).*rand + 0.01);
    deviation = round(N*rn);
    
    
    seq = random_sequence(b_true, N);
    [b_predict,n,func_name] = f(seq, N, deviation, b_true);
    loss(t) = n/N + 1-hit(b_predict, b_true, deviation);
    tot_penalty = tot_penalty + loss(t);
    fprintf('N=%d,n=%d,var=%f,B_predict=%d,tot_penalty=%f,hit=%d\n',N, n, N^2/n^2,b_predict,tot_penalty, 1-hit(b_predict, b_true, deviation))
end
loglog(loss)
mean_penalty = tot_penalty / T;
score = 1 - mean_penalty;
fprintf([func_name ' Mean score {score:%.3f} on trials {T:%0.2f}. The higher the better :)\n'],score,T)
end


% #######################################
% # Define your function here. They should have the same arguments as
% # `my_silly_f`. Create new ones or just override this one.
% #######################################
function  my_silly_f(sequence, N, m,b_true)
% '''
% Arguments:
% sequence: a generator that yields (0, num0), ..., (N-1, numN-1)
%     N: the upper limit of the sequence
% m: the allowed deviation of `b_predict`.
% '''
% # naive implementation: We just go through 50% of the
% # dataset and return the maximum value, hoping that is a good estimate.
% # Notice that we need to return `(n, b_predict)`, not `b_predict` alone!
%
silly_counter = 0;
for i=1:length(sequence)
    b_predict = max(sequence(1:i));
    n = round(b_predict/(1-b_predict+ b_true));
    silly_counter = silly_counter+1;
    if silly_counter*50 >= N
        b_predict = round(b_predict * 1.50); %50% of total data
        break
    end
end
end

function  [b_predict,n,namestr] = another_silly_that_goes_through_all_data(sequence, N, m, b_true)
%         # since we go through all the data we are certain that we have the correct
%         # value: `b_predict == b_true`, but `n/N == N/N == 1`, so the total score
%         # will be 0 in this case.
st = dbstack;
namestr = st.name;
% [val,idx] = sort(sequence);
% b_predict = val(end);
% n = idx(end);
%b_predict = -inf;
% for i=1:length(sequence)
%     b_predict = max(b_predict, sequence(i));
% end


b_predict = max(sequence);
n = length(sequence)-1;

end