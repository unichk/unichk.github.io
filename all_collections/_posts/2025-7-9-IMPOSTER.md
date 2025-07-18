---
title: IMPOSTER - Inject Multi-agent Policy in Oracle-Only with Spatiotemporal Triggered Embedding via Reward ඞ
date: 2025-7-9
categories: [ais3, research]
---

# 1 Introduction

Cooperative multi‑agent reinforcement learning has enabled impressive coordination in tasks such as swarm robotics and autonomous navigation. However, the reliance on third‑party models or ability to swap model raises security concerns: an adversary could stealthily implant a backdoor into one agent’s policy that remains dormant until triggered, at which point it derails the entire team. To date, backdoor attacks in multi‑agent settings have assumed white‑box access—manipulating rewards or network parameters during training, which is unrealistic when policies are deployed as opaque services.

This project aims to develop a black-box approach for injecting a stealth backdoor into a single agent’s policy within cooperative multi-agent environments, such that triggering the backdoor can derail the entire team.

# 2 Related Work

Existing research on backdoor attacks in deep reinforcement learning (DRL) is limited. Furthermore, prior studies assume a white-box threat model in which the attacker has full access to the reward function during target-policy training. Although imitation learning is a well-established field, no previous work has explored implanting backdoors via imitation learning.

Current white-box techniques in multi-agent cooperative environments employ a range of triggers, including instantaneous observation-based triggers{% cite MARNet %}, external signal combine with a trigger policy{% cite chen2022backdoorattacksmultiagentcollaborative %}, and spatiotemporal triggers{% cite yu2024spatiotemporalstealthybackdoorattack %}{% cite yu2025blaststealthybackdoorleverage %}.

During training, contemporary reward-hacking techniques include modifying the original reward function{% cite MARNet %}{% cite yu2024spatiotemporalstealthybackdoorattack %}, distance between benign and abnormal observations{% cite chen2022backdoorattacksmultiagentcollaborative %}, encouraging action discrepancies from other target agents when the backdoor is triggered{% cite yu2024spatiotemporalstealthybackdoorattack %}{% cite yu2025blaststealthybackdoorleverage %}, and, in more advanced schemes, learning fail observations to guide the policy{% cite yu2025blaststealthybackdoorleverage %}. 

# 3 Threat Model

## 3.1 Scenario and Attacker’s Objective

This project consider a possible attack scenario in which an attacker infiltrates a multi-agent distributed system by assuming the role of a user, either directly or via an outsourced model. Given a pre-trained clean cooperative policy (which could be rule-based rather than learned), the adversary can stealthily swap it for a malicious policy and deploy it in the team as a hidden "traitor" within the team.

The attacker’s objective is to compromise the entire team when the backdoor in a single agent is triggered. To achieve both effectiveness and stealth, the backdoored agent must (1) behave identically to clean agents in the absence of the trigger and (2) exhibit disruptive, malicious behavior upon trigger activation. Moreover, the trigger mechanism itself should be covert, rare, and require only a low poisoning rate.

## 3.2 Black-box Limitations

For this project, the black-box attack is subject to the following constraints:

1. **Policy Access** The attacker may only query the target policy by providing an observation and receiving the corresponding action. No information about the policy’s logic, network architecture, or parameter values is available.
2. **Training ignorance** The attacker has no prior knowledge of the policy’s training process, including the learning algorithm, reward function, or hyperparameters.
3. **Environment transparency** The attacker has full access to the environment’s state-transition function, as the environment is assumed to be obtainable (e.g. publicly documented).

## 3.3 Problem Definition

In this section, the IMPOSTER agent in cooperative multi-agent environments is modeled as a decentralized partially observable Markov decision process (Dec-POMDP), defined by the tuple $$(N, S, O, A, T, R, \gamma)$$

- $$N = \{1, \dots, n\}$$ denotes the set of team agents. Agent $$k$$ is the backdoor-implanted IMPOSTER agent following policy $$\pi^I$$; all other agents remain clean and follow the target policy $$\pi^T$$.

- $$S$$ denotes the global environmental state space. Although $$S$$ may be used to train the target policy, it remains unused for the IMPOSTER agent during both training and testing.

- $$O = O_1 \times\dots\times O_n$$ denotes the joint observations space of all agents. Each agent $$i$$ receives a local observation $$o_{i,t} \in O_i$$ at time step $$t$$, which serves as an input to its policy network $$\pi^I$$ for IMPOSTER agent or $$\pi^T$$ for clean agents.

- $$A = A_1 \times\dots\times A_n$$ denotes the joint action space of all agents. IMPOSTER agent and each clean agent use $$\pi^I(a_{k, t} \mid o_{k, t}): O_k \rightarrow A_k$$ and $$\pi^T(a_{i, t} \mid o_{i, t}): O_i \rightarrow A_i$$ to select action, respectively, where $$a_{i, t} \in A_i$$ denotes the selected action for agent $$i$$ at time step $$t$$.

- $$T: S \times A \rightarrow S$$ denotes the environment state transition function. Given state $$s_t \in S$$ and joint action $$\mathbf{a}_t \in A$$ at time step $$t$$, $$T(s_{t + 1}\mid s_t, \mathbf{a}_t)$$ denotes the probability of transitioning to state $$s_{t + 1} \in S$$ at time step $$t + 1$$. Similarly, $$F(o_{t + 1}\mid o_t, \mathbf{a}_t)$$ is used to denote the observation transition of agent $$i$$.

- $$R: S \times A \rightarrow \mathbb{R}$$ denotes the reward function for agent. After executing joint action $$\mathbf{a}_t \in A$$ in state $$s_t \in S$$ at time step $$t$$, agent $$i$$ will receive reward $$r_{i, t} =  R(s_t, \mathbf{a}_t)$$. Note, under the black-box constraint $$R$$ is unknown to the attacker.

- $$\gamma$$ denotes the temporal discount factor where $$0 \leq \gamma \leq 1$$.

In this project, only a single agent is implanted with the backdoor to preserve stealth and practicality. In the absence of the pre-defined trigger, the backdoored agent behaves identically to clean agents. Once the trigger occurs, however, it switches to disruptive behaviors that influence its teammates and ultimately cause the team to fail.

# 4 Methodology

## 4.1 R2D2

Recurrent Replay Distributed DQN (R2D2){% cite kapturowski2018recurrent %}, extends the Ape-X distributed architecture{% cite horgan2018distributedprioritizedexperiencereplay %} by integrating an LSTM layer after the convolutional encoder, enabling agent to handle partial observation and long-horizon dependencies through sequence modeling. R2D2 combines n-step return targets, double Q-learning, dueling networks, and prioritized sampling. It also store the recurrent hidden states and employs burn-in portion to mitigate the issue caused by zero start states and replaying whole episode trajectories. R2D2 was the first agent to exceed human-level performance in 52 of the 57 Atari games.

## 4.2 SQIL

Soft Q Imitation Learning (SQIL){% cite reddy2019sqilimitationlearningreinforcement %} is a straightforward imitation learning algorithm that can be integrated into any standard Q-learning or off-policy actor-critic algorithm with only minor modifications:

1. Seed the experience replay buffer with expert demonstrations, assigning each transition a constant reward $$r = +1$$.
2. Collect oline experiences by interacting with the environment, add the new experiences to the replay buffer with reward $$r = 0$$.
3. Ensure balanced sampling by drawing equally from expert and online experiences (i.e. 50% each) when updating the agent.

## 4.3 Proposed Method

### 4.3.1 Spatiotemporal Backdoor Trigger

This project adopts a pre-defined spatiotemporal trigger which will be implanted into the IMPOSTER policy during training. The observation of each agent typically include four types of information: its own state, teammates’ state, internal environmental information, and external inputs. The backdoor attack can be triggered when a particular environmental state aries or when an attacker-controlled external input is detected.

A trigger is denoted as $$\Psi = \psi_T \land \dots \land \psi_{T + L - 1}$$, where $$T$$ is the starting time step of the trigger, $$L$$ is the length of the trigger, and for each $$t \in \{T, \dots, T + L - 1\}$$, $$\psi_t = C(o_{k, t})$$. $$C$$ and be any compare operation, for instance, the observation is zero ($$o_{k, t} = \mathbf{0}$$), or the $$i$$-th feature is between 0 and 1 ($$0 \leq o_{k, t, i} \leq 1$$).

### 4.3.2 Attack Framework

![attack framework]({{site.baseurl}}/assets/images/IMPOSTER/framework.png)
<div style = "text-align: center; margin-bottom: 1rem">Figure 1. IMPOSTER attack framework.</div>

This project integrates SQIL{% cite reddy2019sqilimitationlearningreinforcement %} with R2D2{% cite kapturowski2018recurrent %} as the basic framework to address black-box constraints. Experience collection is organized into four scenarios, each using a distinct reward scheme:

**Clean Expert Experience** All agents execute the clean target policy in the absence of any trigger. Following SQIL{% cite reddy2019sqilimitationlearningreinforcement %}, each transition is assigned a constant reward $$r = +1$$ and stored in the expert buffer. These demonstrations support behavior cloning, ensuring that the IMPOSTER agent mimics normal performance when untriggered.

**Clean Oline Experience** The IMPOSTER agent selects action according to the training policy while the others agent follow the clean target policy in the absence of any trigger. As in SQIL{% cite reddy2019sqilimitationlearningreinforcement %}, each transition is receives a constant reward $$r = 0$$ and stored in online buffer. These experiences reinforce the agent’s ability to behave normally when the backdoor remains inactive.

**Poisoned Expert Experience** All agents execute the clean target policy, with the trigger activated at a random time step. Transitions before trigger activation are assigned a constant reward $$r = +1$$ as stander demonstration. After the trigger activates, each subsequent transition receives a constant reward $$r = -1$$ instead. The experiences are also stored in expert buffer as negative demonstrations, marking the normal actions as bad, since normal actions rarely achieve effective team sabotage.

![Poisoned online experience]({{site.baseurl}}/assets/images/IMPOSTER/dup.png)
<div style = "text-align: center; margin-bottom: 1rem">Figure 2. Poisoned online experiences' reward scheme.</div>

**Poisoned Online Experience** With the trigger activated at a random time step, the IMPOSTER agent uses the training policy while the others remain on the clean target policy, transitions are stored in the online buffer.

- Before trigger activation receive each transition receives reward $$r = 0$$ as neutral samples.
- After activation, a parallel "reference" environment is duplicated in which IMPOSTER agent $$k$$ is replaced by a clean policy. let $$o_{i,t}$$ and $$o'_{i,t}$$ denote the observations from the original and reference environment, $$y_t = \left[o_{1, t}, \dots, o_{k - 1, t}, o_{k + 1, t}, \dots, o_{n, t}\right]$$ and $$y'_t = \left[o'_{1, t}, \dots, o'_{k - 1, t}, o'_{k + 1, t}, \dots, o'_{n, t}\right]$$ denote the joint observations of the normal agents. Each transition receives reward

$$
\begin{align}
r &= d(\mathbf{o}_t, \mathbf{o}'_t) \\
&= -\alpha \exp\left[2 \left(\text{cosine_similarity}(y_t, y'_t) - 1\right)\right] - \alpha \exp\left[2 \left(\text{euclidean_similarity}(y_t, y'_t) - 1\right)\right] \\
&= -\alpha \exp\left[2 \left(\frac{y_t \cdot y'_t}{\lVert y_t \rVert \lVert y'_t \rVert} - 1\right)\right] - \alpha \exp\left[2 \left(1 - \frac{\lVert y'_t - y_t \rVert}{\lVert y_t \rVert + \lVert y'_t \rVert} - 1\right)\right].
\end{align}
$$

Such a reward scheme encourages the IMPOSTER agent to act in ways that most significantly alter teammates’ observations, increasing the likelihood of derailing overall team performance.

Compared to prior methods{% cite yu2024spatiotemporalstealthybackdoorattack %}{% cite yu2025blaststealthybackdoorleverage %}, this project's purely observation‑based black‑box evaluation achieves faster training and lower computational overhead by duplicating the environment only once per episode instead of at every time step. This single‑copy approach also preserves the environment instance throughout an episode, allowing the long‑term consequences of actions to be accurately captured.

During training, each episode whether an expert demonstration or an agent experience is poisoned with probability $$p$$ and remains clean with probability $$1 - p$$.

# 5 Results

## 5.1 Evaluation Metrics

<image src = "{{site.baseurl}}/assets/images/IMPOSTER/mpe_simple_spread.gif" style = "max-width: 30%; display: block; margin: auto;"></image>
<div style = "text-align: center; margin-bottom: 1rem">Figure 3. MPE simple spread environment.</div>

This project evaluates performance on the "Simple Spread" task of the Multi‑Agent Particle Environment (MPE){% cite mordatch2017emergence %}{% cite lowe2017multi %}, a cooperative navigation benchmark where $$N = 3$$ agents must learn to cover $$N = 3$$ fixed landmarks while avoiding inter‑agent collisions in a continuous 2D world. Evaluation metrics includes average episode return with and without trigger activate.

The target policy is trained using a standard QMIX benchmark{% cite Akash2022 %} without any modifications, although QMIX’s training implementation is fully white‑box, our black‑box attack does not leverage any internal knowledge of the policy. Imitation is a baseline only using SQIL{% cite reddy2019sqilimitationlearningreinforcement %} and R2D2{% cite kapturowski2018recurrent %}, i.e. poisoning rate $$p = 0$$, as a reference for black-box behavior cloning. Each experiment uses the checkpoint that achieved the highest evaluation return during training instead of the checkpoint from a constant time step. Each evaluation is average over 1,000 episodes.

## 5.2 Poisoning Rate

This section analyzes the effect of varying the poisoning rate $$p$$ on backdoor efficacy. When $$p$$ is low, the IMPOSTER agent maintains near‑normal performance in clean episodes but fails to degrade team performance upon trigger activation, indicating an ineffective backdoor. At $$p = 0.03$$, however, the agent achieves strong returns both with and without the trigger, striking an optimal balance between stealth and attack potency.

<div style = "text-align: center; margin-bottom: 1rem">Table 1. Different poisoning rate results, trigger length \(L\) is fixed at \(5\) and each \(\psi_t : o_{k, t} = \mathbf{0}\).</div>

$$
\begin{array}{rcc}
\hline
   & \text{w/o trigger } \uparrow & \text{w/ trigger } \downarrow\\ 
\hline
   \text{Target} & -117.90 \pm 12.96 & - \\
\hline
   \text{Imitation} & -124.53 \pm 15.64 & - \\
\hline
   p = 0.01 & \mathbf{-127.11 \pm 17.55} & -129.85 \pm 17.37 \\ 
\hline
   p = 0.02 & -127.70 \pm 14.95 & -131.16 \pm 16.31 \\
\hline
   p = 0.03 & \underline{-127.49 \pm 16.35} & \mathbf{-141.07 \pm 19.63} \\
\hline
   p = 0.05 & -127.75 \pm 18.74 & \underline{-134.64 \pm 19.07} \\ 
\hline
\end{array}
$$

## 5.3 Trigger Length

This section analyzes the impact of trigger length $$L$$ on backdoor attack performance. The results reveal no consistent trend between $$L$$ and overall returns; however, setting $$L = 4$$ yields the highest average returns in both clean and triggered conditions.

<div style = "text-align: center; margin-bottom: 1rem">Table 2. Different trigger length results, poisoning rate \(p\) is fixed at \(0.03\), and each \(\psi_t : o_{k, t} = \mathbf{0}\).</div>

$$
\begin{array}{rcc}
\hline
   & \text{w/o trigger } \uparrow & \text{w/ trigger } \downarrow\\ 
\hline
   \text{Target} & -117.90 \pm 12.96 & - \\
\hline
   \text{Imitation} & -124.53 \pm 15.64 & - \\
\hline
   L = 1 & -129.36 \pm 17.28 & -144.26 \pm 18.23 \\ 
\hline
   L = 2 & -127.72 \pm 15.99 & \underline{-144.64 \pm 19.63} \\
\hline
   L = 3 & -130.10 \pm 15.29 & -142.09 \pm 17.27 \\
\hline
   L = 4 & \mathbf{-126.02 \pm 16.23} & \mathbf{-143.07 \pm 18.65} \\ 
\hline
   L = 5 & \underline{-127.49 \pm 16.35} & -141.07 \pm 19.63 \\ 
\hline
\end{array}
$$

## 5.4 Ablation Study

This section investigates the impact of integrating a custom reward $$r = d(\mathbf{o}_t, \mathbf{o}'_t)$$ into the poisoned expert demonstrations. Experimental results demonstrate that this reward enhances the backdoor’s stealthiness while simultaneously amplifying the IMPOSTER agent’s disruptive behavior.

<div style = "text-align: center; margin-bottom: 1rem">Table 3. Ablation study results, poisoning rate \(p\) is fixed at \(0.03\), trigger length \(L\) is fixed at \(4\) and each \(\psi_t : o_{k, t} = \mathbf{0}\). The experiment without reward simply assign \(r = 0\) for each step as normal online experiences.</div>

$$
\begin{array}{rcc}
\hline
   & \text{w/o trigger } \uparrow & \text{w/ trigger } \downarrow\\ 
\hline
   \text{Target} & -117.90 \pm 12.96 & - \\
\hline
   \text{Imitation} & -124.53 \pm 15.64 & - \\
\hline
   \text{w/ reward} & \mathbf{-126.02 \pm 16.23} & \mathbf{-143.07 \pm 18.65} \\ 
\hline
   \text{w/o reward} & -126.15 \pm 17.05 & -141.55 \pm 18.94  \\
\hline
\end{array}
$$

# 6 Conclusion and Discussion

This work has presented a novel black‑box backdoor attack for cooperative multi‑agent environments. Experimental results demonstrate that our method can stealthily embed a backdoor while maintaining near-normal behavior in the absence of a trigger, although its effectiveness is constrained by black‑box limitations. Upon trigger activation, the IMPOSTER agent consistently disrupts team performance. We also show that both the poisoning rate $$p$$ and the trigger length $$L$$ critically affect attack efficacy and stealth, necessitating careful tuning.

For future work, the black‑box setting could be extended to scenarios where the environment transition function itself is concealed from the attacker, leveraging techniques from "Stealthy Imitation"{% cite zhuang2024stealthyimitationrewardguidedenvironmentfree %}. Additionally, alternative threat models warrant exploration, such as distributing the backdoor across multiple agents and designing a composite trigger that activates only when all backdoor components are simultaneously present.

# References

{% bibliography --cited %}

# Project Details

This is a project for 第九屆 AIS3 好厲駭, note the writing cites ChatGPT and BLAST{% cite yu2025blaststealthybackdoorleverage %} a lot, however the underlying research and proposed method are entirely original.

Code: [github](https://github.com/unichk/IMPOSTER)

If you like to cite this project, bibtex:

```bibtex
@online{chang2025IMPOSTER,
    title     = { {{- page.title -}} },
    author    = {Hao-Kai Chang},
    year      = 2025,
    url       = {https://unichk.github.io{{- page.url -}} },
    urldate   = { {{- site.time | date: "%Y-%m-%d" -}} }
}
```

<!-- No dark theme, it breaks the image -->
<script>
    window.onload = function() {
        document.getElementById("dark-mode-toggle").children[0].style.display = 'none'
        document.documentElement.setAttribute("data-theme", "light");
    }
</script>